//
//  AllListingsTableViewCell.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 04/12/21.
//

import UIKit

class AllListingsTableViewCell: UITableViewCell {


    @IBOutlet var imageItem: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var  facilityLabel: UILabel!
    
    @IBOutlet var locationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
