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


// MARK: - Welcome
struct CommentCreateApiRequest: Codable {
    let records: [CommentCreateApiRecord]
}

// MARK: - Record
struct CommentCreateApiRecord: Codable {
    let fields: CommentCreateApiFields
}

// MARK: - Fields
struct CommentCreateApiFields: Codable {
    let user: [String]
    let comment: String
    let listing: [String]
}





// MARK: - CommentListingApiRequest
struct CommentListingApiResponse: Codable {
    let records: [CommentListingApiRecord]
}

// MARK: - CommentListingApiRecord
struct CommentListingApiRecord: Codable {
    let id: String
    let fields: CommentListingApiField
    let createdTime: String
}

// MARK: - CommentListingApiRecord
struct CommentListingApiField: Codable {
    let comment: String
    let nameFromUser: [String]

    enum CodingKeys: String, CodingKey {
        case comment
        case nameFromUser = "name (from user)"
    }
}



class ListingDetailsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
    var titleText = ""
    var facilitiesText = ""
    var locatonText = ""
    var listingImageText = ""
    var listingId = ""
    var descriptionText = ""
    var favorites = [String]()
    var comments = [Comment]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var facilitiesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var listingImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var commentText: UITextField!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    
    
    var users = [User]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    var isFavorite = true
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        commentLabel.isHidden = true
        titleLabel.text = titleText
        facilitiesLabel.text = facilitiesText
        locationLabel.text = locatonText
        if listingImageText != ""{
            let newImageData = Data.init(base64Encoded: listingImageText, options: .init(rawValue: 0))
            listingImage.image = UIImage(data: newImageData!)
        }
        descriptionTextView.text = descriptionText

        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetchComments()
    }
    
    func fetchComments(){
        let semaphore = DispatchSemaphore (value: 0)
        let url = Constants.apiUrl + "/Comment?filterByFormula=AND(({listing}='"+titleText+"'))"
        
        var request = URLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!,timeoutInterval: Double.infinity)
        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
            let jsonDecoder = JSONDecoder()
            do {
                let apiResponse = try jsonDecoder.decode(CommentListingApiResponse.self,from: data)
                //No users are found
                var comments =  [Comment]()
                for record in apiResponse.records {
                    let comment = Comment()
                    comment.comment = record.fields.comment
                    comment.userName = record.fields.nameFromUser[0]
                    comment.date = record.createdTime
                    comments += [comment]
                    
                }
                self.comments = comments
                print("Comes here")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
    
            }catch let jsonError {
                print(jsonError)
            }
          semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    
    
    @IBAction func didTapAddComment(_ sender: Any) {
        commentLabel.isHidden = true
        if commentText.text == "" {
            commentLabel.text =  "Comment is required"
            commentLabel.isHidden = false
            return
        }
        let userIds = [users[0].id!]

        let listingIds = [listingId]
        let url = Constants.apiUrl+"/Comment";
        
        let fields = CommentCreateApiFields(user:userIds,comment: commentText.text!,listing:listingIds)
        let postData = CommentCreateApiRequest(records: [CommentCreateApiRecord(fields: fields)])
        
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue(Constants.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("brw=brwD8OHuk7iMnJBzj", forHTTPHeaderField: "Cookie")
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
              let alert = UIAlertController(title: "", message: "Comment created successfully",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok",style: .default, handler: { (action) in
                    self.fetchComments()
                }))
                self.present(alert, animated: true)
            }
         
            
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()

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
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill"), style: .plain, target: self, action: #selector(didTapSaveListing))
                }else{
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(didTapSaveListing))
                }
            }
     
        }catch {
            
        }

    }
    
    @objc func didTapSaveListing(_ sender: Any) {
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
                print(httpResponse.statusCode)
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
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill"), style: .plain, target: self, action: #selector(self.didTapSaveListing))
                }else{
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(self.didTapSaveListing))

                }
            }
            semaphore.signal()
            return

        }

        task.resume()
        semaphore.wait()

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row]
        cell.commentLabel.text = comment.comment
        cell.nameLabel.text = comment.userName
        cell.dateLabel.text = comment.date
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
  
}
