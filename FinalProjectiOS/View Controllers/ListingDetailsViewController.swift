//
//  ListingDetailsViewController.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 02/12/21.
//

import UIKit

class ListingDetailsViewController: UIViewController {
    var titleText = ""
    var facilitiesText = ""
    var locatonText = ""
    var listingImageText = ""
    var descriptionText = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var facilitiesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var listingImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText
        facilitiesLabel.text = facilitiesText
        locationLabel.text = locatonText
        if listingImageText != ""{
            let newImageData = Data.init(base64Encoded: listingImageText, options: .init(rawValue: 0))
            listingImage.image = UIImage(data: newImageData!)
        }
        descriptionTextView.text = descriptionText
    }
}
