//
//  SpotViewModel.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import FirebaseFirestore
import Foundation

@MainActor
class SpotViewModel: ObservableObject {
    @Published var spot = Spot()
    
    func saveSpot(spot: Spot) async -> Bool {
        let dataBase = Firestore.firestore() // ignore any error
        
        if let id = spot.id { // spot must already exist, so save
            do {
                try await dataBase.collection("spots").document(id).setData(spot.dictionary)
                print("😎 Data updates successfully.")
                return true
            } catch {
                print("🤬 ERROR: Could not update data in 'spots' \(error.localizedDescription)")
                return false
            }
        } else { // no id? Then this must be a new spot to add
            do {
                let documentRef = try await dataBase.collection("spots").addDocument(data: spot.dictionary)
                self.spot = spot
                self.spot.id = documentRef.documentID
                print("🐣 Data added successfully.")
                return true
            } catch {
                print("🤬 ERROR: Could not create an new spot \(error.localizedDescription)")
                return false
            }
        }
    }
}
