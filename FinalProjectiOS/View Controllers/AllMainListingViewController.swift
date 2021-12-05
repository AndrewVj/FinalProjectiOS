//
//  AllMainListingViewController.swift
//  FinalProjectiOS
//
//  Created by ashok on 04/12/2021.
//

import UIKit

class AllMainListingViewController: ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = storyboard?.instantiateViewController(withIdentifier: "AllListingsTableView") as! ListingsTableViewController
        self.navigationController?.pushViewController(vc, animated: true)
        // Do any additional setup after loading the view.
    }

}
