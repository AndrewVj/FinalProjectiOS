//
//  MyListingViewController.swift
//  FinalProjectiOS
//
//  Created by ashok on 02/12/2021.
//

import UIKit

class MyListingViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AllListingsTableView") as! ListingsTableViewController
        vc.navigationItem.setHidesBackButton(true, animated: true)
        vc.navigationItem.title =  "My listings"
        vc.listingType = "my"
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
