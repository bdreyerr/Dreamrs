//
//  User.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/27/23.
//

import Foundation

struct User: Codable {
    var firstName: String?
    var lastName: String?
    var email: String?
    var handle: String?
    var following: [String]?
    var followers: [String]?
    var karma: Int?
}
