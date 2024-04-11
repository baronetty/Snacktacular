//
//  Spot.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import FirebaseFirestoreSwift
import Foundation

struct Spot: Identifiable, Codable {
    @DocumentID var id: String?
    var name = ""
    var address = ""
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address]
    }
}
