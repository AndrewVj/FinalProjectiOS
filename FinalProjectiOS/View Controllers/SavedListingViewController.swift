//
//  SavedListingViewController.swift
//  FinalProjectiOS
//
//  Created by Karandeep Singh on 02/12/2021.
//

import UIKit

class SavedListingViewController: UIViewController {

    
    override func viewWillAppear(_ animated: Bool) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AllListingsTableView") as! ListingsTableViewController
        vc.navigationItem.setHidesBackButton(true, animated: true)
        vc.navigationItem.title = "Saved listings"
        vc.listingType = "saved"
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}
