//
//  RegisterViewController.swift
//  FinalProjectiOS
//
//  Created by Karandeep Singh on 30/11/2021.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Hide the label
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        passwordLabel.isHidden = true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //Outlet initialization
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    var emailExist = false
    
    @IBAction func didTapRegister(_ sender: UIButton) {
        //Hide all the labels
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        passwordLabel.isHidden = true
        
        
        let emailText = String(email.text!)
        let nameText = String(email.text!)
        let passwordText = String(password.text!)
        
        //Check if the fields are valid or not
        var isValid = true
        if email.text == ""{
            isValid = false
            emailLabel.text = "Email is required"
            emailLabel.isHidden = false
        }else{
            if(!isValidEmail(emailText)){
                isValid = false
                emailLabel.text = "Email is not valid"
                emailLabel.isHidden = false
            }
        }
        
        if name.text == "" {
            isValid = false
            nameLabel.text = "Name is required"
            nameLabel.isHidden = false
        }
        
        if password.text == "" {
            isValid = false
            passwordLabel.text = "Password is required"
            passwordLabel.isHidden = false
        }
        
        if !isValid {
            return
        }
        
    

        //Check if email exisits or not
        let _emailExist = checkIfEmailExist(email: emailText)
    
        if _emailExist {
            emailLabel.text = "Email already exist"
            emailLabel.isHidden = false
            return
        }
        
        //If not email already exist create new user
        
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\n  \"records\": [\n    {\n      \"fields\": {\n        \"name\": \""+nameText+"\",\n        \"email\": \""+emailText+"\",\n        \"password\": \""+passwordText+"\"\n      }\n    }\n  ]\n}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: Constants.apiUrl + "/User")!,timeoutInterval: Double.infinity)
        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       // request.addValue("brw=brwD8OHuk7iMnJBzj", forHTTPHeaderField: "Cookie")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message: "Registered successfully",preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "Ok",style: .default, handler: { (action) in
                      _ = self.navigationController?.popViewController(animated: true)
                  }))
                  self.present(alert, animated: true)
                
            }
          print(String(data: data, encoding: .utf8)!)

          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
    //Check if this is valid email or not
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //Make api call to check if email exisits or not
    private func checkIfEmailExist(email: String) -> Bool {
      
        let semaphore = DispatchSemaphore (value: 0)

        let apiUrl = Constants.apiUrl + "/Users?filterByFormula=AND(({email}='"+email+"'))"
 
        var request = URLRequest(url: URL(string: apiUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!,timeoutInterval: Double.infinity)

        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
            let jsonDecoder = JSONDecoder()
            do {
                let apiResponse = try jsonDecoder.decode(ApiResponse.self,from: data)
                //No users are found
                if(apiResponse.records.count > 0) {
                    self.emailExist = true
                    semaphore.signal()
                    return
                }
                
            }catch let jsonError {
                print(jsonError)
            }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }
    
        task.resume()
        semaphore.wait()
        
        return emailExist
    }
    
    
    //Redirect user to login page for tapping sign in page
    @IBAction func didTabSignIn(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "signInStoryBoard") as! UIViewController
        vc.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController:vc)
        // Creating a navigation controller with VC1 at the root of the navigation stack.
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated:true, completion: nil)
    }
    
 
}

