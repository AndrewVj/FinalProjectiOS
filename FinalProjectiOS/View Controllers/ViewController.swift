//
//  ViewController.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 29/11/21.
//

import UIKit

struct Field: Codable {
    let email: String
    let password: String
    let name: String
}

struct Record: Codable {
    let id: String
    let fields : Field
    let createdTime : String
}

struct ApiResponse : Codable {
    let records : [Record]
}



class ViewController: UIViewController {
    //Outlet intliazaton
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet var  spinner: UIActivityIndicatorView!
    //For data loading
    var users : [User]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    var isDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.hidesWhenStopped = true
    }
    
   
    @IBAction func handleSignInClick(_ sender: UIButton) {
   
        //Reset the values before validation
        passwordLabel.isHidden = true
        emailLabel.isHidden = true

        //Check whether the input fields are empty or not
        var isValid = true
        if emailAddress.text == "" {
            isValid = false
            emailLabel.text = "Email is required"
            emailLabel.isHidden = false
        }
        if password.text == "" {
            isValid = false
            passwordLabel.text = "Password is required"
            passwordLabel.isHidden = false
        }
        
        if !isValid {
            return
        }
        
        if isDataLoading {
            return
        }
        let semaphore = DispatchSemaphore (value: 0)

        
        let emailText = String(emailAddress.text!)
        let passwordText = String(password.text!)

        //Make api call
        let apiUrl = Constants.apiUrl + "/User?filterByFormula=AND(({email}='"+emailText+"'),({password}='"+passwordText+"'))"
        
 
        var request = URLRequest(url: URL(string: apiUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!,timeoutInterval: Double.infinity)

        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("brw=brwD8OHuk7iMnJBzj", forHTTPHeaderField: "Cookie")
        spinner.startAnimating()
    
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            semaphore.signal()
            return
          }
            let jsonDecoder = JSONDecoder()
            do {
                let apiResponse = try jsonDecoder.decode(ApiResponse.self,from: data)

                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        //No users are found
                        if (apiResponse.records.count == 0 ){
                            self.passwordLabel.text = "Email or password is incorrect"
                            self.passwordLabel.isHidden = false
                        }
                        //Declare the user
                        let currentUser  = User(context: self.context)
                        currentUser.email = apiResponse.records[0].fields.email
                        currentUser.name = apiResponse.records[0].fields.name
                        currentUser.id = apiResponse.records[0].id

                        do{
                            try self.context.save()
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "tabbarMain") as! UITabBarController
                            vc.modalPresentationStyle = .fullScreen
                            let navController = UINavigationController(rootViewController:vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
                            navController.modalPresentationStyle = .fullScreen
                            self.present(navController, animated:true, completion: nil)

                            print("Comes here")
                        }catch let error{
                            print("Unexpected error: \(error).")
                        }
                        
                    }
                 
           
                semaphore.signal()

                
            }catch let jsonError {
                print(jsonError)
            }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }
    
        task.resume()
        semaphore.wait()
    }

}

