//
//  CreateListingViewController.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 02/12/21.
//

import UIKit
import Photos


// MARK: - Welcome
struct ListingApiRequest: Codable {
    let records: [ListingApiRequestRecord]
}

// MARK: - Record
struct ListingApiRequestRecord: Codable {
    let fields: ListingApiRequestFields
}

// MARK: - Fields
struct ListingApiRequestFields: Codable {
    let title, photos, facilities, fieldsDescription: String
    let location: String
    let user: [String]

    enum CodingKeys: String, CodingKey {
        case title, photos, facilities
        case fieldsDescription = "description"
        case location, user
    }
}


class CreateListingViewController: UIViewController {
    
    //Outlet initizations

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var nameLabel: UIView!
    @IBOutlet var nameInput: UITextField!
    
    @IBOutlet var nameMainLabel: UILabel!
    @IBOutlet var locationInput: UITextField!
    
    @IBOutlet var locationLabel: UILabel!
    
    
    @IBOutlet var facilityInput: UITextField!
    
    @IBOutlet var facilityLabel: UILabel!
    
    @IBOutlet var descriptionInput: UITextField!
    
    @IBOutlet var photoLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    
    
    //For coredata
    var users = [User]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide all label
        nameMainLabel.isHidden = true
        locationLabel.isHidden = true
        facilityLabel.isHidden = true
        descriptionLabel.isHidden = true
        photoLabel.isHidden = true
        fetchUser()
    }
    
    
    func fetchUser(){
        do{
            self.users = try context.fetch(User.fetchRequest())
        }catch {
            
        }

    }
    
    @IBAction func createListingButton(_ sender: Any) {
        nameMainLabel.isHidden = true
        locationLabel.isHidden = true
        facilityLabel.isHidden = true
        descriptionLabel.isHidden = true
        photoLabel.isHidden = true
        
        var isValid = true
        
        //Fields validations
        if nameInput.text == "" {
            nameMainLabel.text = "Name is required"
            nameMainLabel.isHidden = false
            isValid = false
        }
        
        if locationInput.text == "" {
            locationLabel.text = "Location is required"
            locationLabel.isHidden = false
            isValid = false
        }
        
        if facilityInput.text == "" {
            facilityLabel.text = "Location is required"
            facilityLabel.isHidden = false
            isValid = false
        }
        
        if descriptionInput.text == "" {
            descriptionLabel.text = "Description is required"
            descriptionLabel.isHidden = false
            isValid = false
        }
        
        if imageView.image == nil {
            photoLabel.text = "Photo is required"
            photoLabel.isHidden = false
            isValid = false
        }
      
        if users.count == 0 {
            return
        }
        
        let userIds = [users[0].id!]
        
      
        //We are encoding data to base64 which is accepted by api
        let a = imageView.image?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
        if !isValid {
            return
        }
        let url = Constants.apiUrl+"/Listing";
        let fields = ListingApiRequestFields(title: nameInput.text!, photos: a, facilities: facilityInput.text!, fieldsDescription:descriptionInput.text!, location: locationInput.text!, user: userIds)
        let postData = ListingApiRequest(records: [ListingApiRequestRecord(fields: fields)])
        
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        guard let uploadData = try? JSONEncoder().encode(postData) else {
            return
        }
        request.httpBody = uploadData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode != 200 {
                    self.showToast("Image too large . Please select another image")
                    return
                }
            }
            
            guard let _ = data else {
            semaphore.signal()
            return
           }
            DispatchQueue.main.async {
              let alert = UIAlertController(title: "", message: "Listing created successfully",preferredStyle: .alert)
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
    
    //For showing upload gallery
    @IBAction func didTapButton(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

}

extension CreateListingViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //Check for the pick photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let key = "UIImagePickerControllerEditedImage"
        if let image = info[UIImagePickerController.InfoKey(rawValue: key)] as? UIImage {
            imageView.image = image
        }
        //Store the image in the ui view
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
