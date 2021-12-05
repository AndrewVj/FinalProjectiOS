//
//  CommentTableViewCell.swift
//  FinalProjectiOS
//
//  Created by ashok on 05/12/2021.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
