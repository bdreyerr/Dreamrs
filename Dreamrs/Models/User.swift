//
//  User.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/27/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var handle: String?
    var following: [String]?
    var followers: [String]?
    var numDreams: Int?
    var karma: Int?
}
