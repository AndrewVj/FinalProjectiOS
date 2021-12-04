//
//  AllListingsTableViewCell.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 04/12/21.
//

import UIKit

class AllListingsTableViewCell: UITableViewCell {

    @IBOutlet weak var allListingsCellTitleLabel: UILabel!
    @IBOutlet weak var allListingsCellImageView: UIImageView!
    @IBOutlet weak var allListingsCellLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
