//
//  Dream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/27/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Dream : Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var authorId: String?
    var authorHandle: String?
    var title: String?
    var plainText: String?
    var archivedData: Data?
    var date: String?
    var rawTimestamp: Date?
    var dayOfWeek: String?
    var karma: Int?
    var sharedWithFriends: Bool?
    var sharedWithCommunity: Bool?
    var tags: [[String : String]]?
}
