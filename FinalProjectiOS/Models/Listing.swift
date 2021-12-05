//
//  Listing.swift
//  FinalProjectiOS
//
//  Created by ashok on 02/12/21.
//

import Foundation

class Listing: Codable {
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var facilities: String = ""
    var image: String = ""
    var location: String = ""
    var favorite = [String]()
}
