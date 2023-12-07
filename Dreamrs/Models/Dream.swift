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

struct Dream: Codable {
    @DocumentID var id: String?
    var authorId: String?
    var authorHandle: String?
    var text: [FormattedText]?
    var date: String?
    var karma: Int?
}
