//
//  RootViewController.swift
//  FinalProjectiOS
//
//  Created by ashok on 05/12/2021.
//

import UIKit

class RootViewController: UIViewController {

    var users : [User]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.fetchUser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func fetchUser(){
        do{
            self.users = try context.fetch(User.fetchRequest())
            //Users already registered
            if(self.users!.count > 0 ){
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarMain")
                vc.modalPresentationStyle = .fullScreen
                navigationController?.present(vc, animated: false)
            }else{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signInStoryBoard")
                vc.modalPresentationStyle = .fullScreen
                navigationController?.present(vc, animated: false)
            }
        }catch {
            
        }

    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
