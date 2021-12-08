//
//  ListingsTableViewController.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 02/12/21.
//

import UIKit

struct AllListingApiResponse: Codable {
    let records: [ListingRecord]
}

// MARK: - Record
struct ListingRecord: Codable {
    let id: String
    let fields: ListingFields
    let createdTime: String
}

// MARK: - Fields
struct ListingFields: Codable {
    let title, fieldsDescription, facilities, photos: String
    let location: String
    let user, emailFromUser, nameFromUser,favorite: [String]?

    enum CodingKeys: String, CodingKey {
        case title
        case fieldsDescription = "description"
        case facilities, photos, location, user
        case emailFromUser = "email (from user)"
        case nameFromUser = "name (from user)"
        case favorite = "favorite"
    }
}



class ListingsTableViewController: UITableViewController {
    //For getting data from core data
    var users = [User]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var listingType = ""
    
    var listings =  [Listing]()
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUser()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    //Fetching the users from db
    func fetchUser(){
        do{
            self.users = try context.fetch(User.fetchRequest())
            if self.users.count > 0 {
                let userEmail = users[0].email
                self.loadDataFromApi(email:userEmail,userId: users[0].id)
            }

        }catch {
            
        }

    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    //Pass the listing details to another api
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.listings.count > 0 ){
            let listing = self.listings[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListingDetailView") as! ListingDetailsViewController
            vc.locatonText = listing.location
            vc.titleText = listing.title
            vc.facilitiesText = listing.facilities
            vc.descriptionText = listing.description
            vc.listingImageText = listing.image
            vc.favorites = listing.favorite
            vc.listingId = listing.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  self.listings.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllListingsCell", for: indexPath) as! AllListingsTableViewCell
        if (self.listings.count > 0 ){
            let listing = self.listings[indexPath.row]
            let newImageData = Data.init(base64Encoded: listing.image, options: .init(rawValue: 0))
            cell.imageItem.image = UIImage(data: newImageData!)
            cell.facilityLabel.text = listing.facilities
            cell.nameLabel.text = listing.title
            cell.locationLabel.text = listing.location
        }
        return cell
    }
    
    
    
    
    //Loads all the listings from the api
    func loadDataFromApi(email: String?,userId: String?){
        guard let email = email else {
            return
        }
        guard let userId = userId else {
            return
        }
        let semaphore = DispatchSemaphore (value: 0)
        var filterByFormula =  ""
        switch listingType {
           case "main":
            filterByFormula = ""
           case "my" :
               filterByFormula = "?filterByFormula=AND(({email (from user)}='"+email+"'))"
           case "saved":
              filterByFormula = ""
           default:
            return
        }
        let url = Constants.apiUrl + "/Listing" + filterByFormula
        
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
                let apiResponse = try jsonDecoder.decode(AllListingApiResponse.self,from: data)
                //No users are found
                var listings =  [Listing]()
                for record in apiResponse.records {
        
                    let listing = Listing()
                    listing.image = record.fields.photos
                    listing.location = record.fields.location
                    listing.description = record.fields.fieldsDescription
                    listing.title = record.fields.title
                    listing.facilities = record.fields.facilities
                    listing.id = record.id
                    listing.favorite = self.getFavioriteListing(faviorites: record.fields.favorite)
                    //Check if the listing is in faviorite or not
                    if self.listingType == "saved" {
                        var isFaviorite = false
                       
                        for favorite in listing.favorite {
                            print(favorite,userId)
                            if favorite == userId {
                                isFaviorite = true
                            }
                        }
                        if isFaviorite {
                            listings += [listing]
                        }
                    }else{
                        listings += [listing]
                    }
                
                }
                self.listings = listings
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
    
    private func getFavioriteListing(faviorites: [String]?) -> [String]{
        guard let faviouriteData = faviorites else {
            return [String]()
        }
        
        return faviouriteData

    }
    

}
