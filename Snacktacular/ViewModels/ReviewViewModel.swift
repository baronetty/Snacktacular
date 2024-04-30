//
//  ReviewViewModel.swift
//  Snacktacular
//
//  Created by Leo  on 30.04.24.
//

import FirebaseFirestore
import Foundation

class ReviewViewModel: ObservableObject {
    @Published var review = Review()
    
    func saveReview(spot: Spot, review: Review) async -> Bool {
        let dataBase = Firestore.firestore() // ignore any error
        
        let collectionString = "spots/\(spot.id ?? "")/reviews"
        
        
        if let id = review.id { // review must already exist, so save
            do {
                try await dataBase.collection(collectionString).document(id).setData(review.dictionary)
                print("😎 Data updates successfully.")
                return true
            } catch {
                print("🤬 ERROR: Could not update data in 'reviews' \(error.localizedDescription)")
                return false
            }
        } else { // no id? Then this must be a new review to add
            do {
                _ = try await dataBase.collection(collectionString).addDocument(data: review.dictionary)
                print("🐣 Data added successfully.")
                return true
            } catch {
                print("🤬 ERROR: Could not create an new review in 'reviews' \(error.localizedDescription)")
                return false
            }
        }
    }
}
