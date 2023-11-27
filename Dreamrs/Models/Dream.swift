//
//  Dream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/27/23.
//

import Foundation

struct Dream: Codable {
    var authorId: String?
    var authorHandle: String?
    var text: [[String: [Bool]]]?
    var date: Date?
//    var timestamp: Timestamp?
}
