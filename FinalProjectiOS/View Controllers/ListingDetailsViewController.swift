//
//  ListingDetailsViewController.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 02/12/21.
//

import UIKit

// MARK: - Welcome
struct ListingUpdateApiRequest: Codable {
    let records: [ListingUpdateApiRecord]
}

// MARK: - Record
struct ListingUpdateApiRecord: Codable {
    let fields: ListUpdateApiRequestField
    let id: String
}

// MARK: - Fields
struct ListUpdateApiRequestField: Codable {
    let favorite: [String]
}


class ListingDetailsViewController: UIViewController {
    var titleText = ""
    var facilitiesText = ""
    var locatonText = ""
    var listingImageText = ""
    var listingId = ""
    var descriptionText = ""
    var favorites = [String]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var facilitiesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var listingImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    var isFavorite = true
    
    
    var users = [User]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        titleLabel.text = titleText
        facilitiesLabel.text = facilitiesText
        locationLabel.text = locatonText
        if listingImageText != ""{
            let newImageData = Data.init(base64Encoded: listingImageText, options: .init(rawValue: 0))
            listingImage.image = UIImage(data: newImageData!)
        }
        descriptionTextView.text = descriptionText
    }
    
    
    func fetchUser(){
        do{
            self.users = try context.fetch(User.fetchRequest())
            if self.users.count > 0 {
              var isListingSaved = false
                for favorite in self.favorites {
                    if favorite == self.users[0].id {
                        isListingSaved = true
                    }
                }
                if isListingSaved {
                    self.saveButton.setTitle("Remove from saved", for: .normal)
                }
            }
     
        }catch {
            
        }

    }
    
    @IBAction func didTapSaveListing(_ sender: Any) {
        let userId = users[0].id!
        
        var innerFaviorites = self.favorites
        var removeAt = -1
        var index = 0
        for item in innerFaviorites {
            if item == userId {
                removeAt = index
            }
            index += 1
        }
    
        //Item is faviorited
        if removeAt > -1 {
            innerFaviorites.remove(at: removeAt)
            self.isFavorite = false
        }else{
            innerFaviorites += [userId]
            self.isFavorite = true
        }
        self.favorites = innerFaviorites
     
        let url = Constants.apiUrl+"/Listing";
        let fields = ListUpdateApiRequestField(favorite: innerFaviorites)
        let postData = ListingUpdateApiRequest(records: [ListingUpdateApiRecord(fields: fields,id:listingId)])
        
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("brw=brwD8OHuk7iMnJBzj", forHTTPHeaderField: "Cookie")
        request.httpMethod = "PATCH"
     
        guard let uploadData = try? JSONEncoder().encode(postData) else {
            print("Comes here")
            return
        }
        request.httpBody = uploadData
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode != 200 {
                    print(httpResponse.statusCode)
                    return
                }
            }
         
           guard let _ = data else {
            semaphore.signal()
            return
           }
            DispatchQueue.main.async {
                if self.isFavorite {
                    self.saveButton.setTitle("Remove from saved", for: .normal)
                }else{
                    self.saveButton.setTitle("Save listing", for: .normal)
                }
            }
            semaphore.signal()
            return

        }

        task.resume()
        semaphore.wait()

        
    }
    
 
    
  
}
