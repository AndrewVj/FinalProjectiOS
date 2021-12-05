//
//  UserDetailViewController.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 02/12/21.
//

import UIKit

struct UserDetailApiRequest: Codable {
    let records: [UserDetailsApiRecord]
}

struct UserDetailsApiRecord: Codable {
    let id: String
    let fields: UserDetailsApiFields
}

struct UserDetailsApiFields: Codable {
    let name, email, password: String?

    enum CodingKeys: String, CodingKey {
        case name, email, password
    }
    
    // But we want to store `fullName` in the JSON anyhow
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(email, forKey: .email)
            if password != nil && password != "" {
                try container.encode(password, forKey: .password)
            }
          
        }
    
}


class UserDetailViewController: UIViewController {


    @IBOutlet var nameInput: UITextField!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailInput: UITextField!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordInput: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    
    var users = [User]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.isHidden = true
        nameLabel.isHidden = true
        passwordLabel.isHidden = true
        fetchUser()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func didTabUpdateInformation(_ sender: Any) {
        var isValid = true
        if nameInput.text == "" {
            isValid = false
            nameLabel.text = "Name is required"
        }
        if emailInput.text == "" {
            isValid = false
            emailLabel.text = "Email is required"
        }
        
        if !isValid {
            return
        }
        let url = Constants.apiUrl+"/User";

        var fields = UserDetailsApiFields(name: nameInput.text, email: emailInput.text,password: nil)
        
        if passwordLabel.text != "" {
            fields = UserDetailsApiFields(name: nameInput.text, email: emailInput.text,password: passwordInput.text)
        }
        let userId = users[0].id!

        let postData = UserDetailApiRequest(records: [UserDetailsApiRecord(id:userId, fields: fields)])
        
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("brw=brwD8OHuk7iMnJBzj", forHTTPHeaderField: "Cookie")
        request.httpMethod = "PATCH"
        guard let uploadData = try? JSONEncoder().encode(postData) else {
            return
        }
        request.httpBody = uploadData
        print("Comes here")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
           guard let _ = data else {
            semaphore.signal()
            return
           }
            DispatchQueue.main.async {
              let alert = UIAlertController(title: "", message: "Details updated successfully",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok",style: .default, handler: { (action) in
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarMain")
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(vc, animated: true)
                }))
                self.present(alert, animated: true)
            }
         
            
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        
        
    }
    
    @IBAction func signOutButton(_ sender: UIButton) {
        
        let userToRemove = users[0]
        self.context.delete(userToRemove)
        do{
            print("Comes here")
            try self.context.save()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signInStoryBoard")
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true)
        }catch{
            
        }
        
    }
    
    func fetchUser(){
        do{
            self.users = try context.fetch(User.fetchRequest())
            if self.users.count > 0 {
                let userEmail = users[0].email
                self.emailInput.text = userEmail
                self.nameInput.text = users[0].name
            }
        }catch {
            
        }

    }
    
    
}
