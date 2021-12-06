//
//  AllMainListingViewController.swift
//  FinalProjectiOS
//
//  Created by Andrew Vijay on 02/12/2021.
//

import UIKit

class AllMainListingViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AllListingsTableView") as! ListingsTableViewController
        vc.navigationItem.setHidesBackButton(true, animated: true)
        vc.listingType = "main"
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
