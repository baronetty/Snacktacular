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
    
    func deleteReview (spot: Spot, review: Review) async -> Bool {
        let dataBase = Firestore.firestore()
        guard let spotID = spot.id, let reviewID = review.id else {
            print("🤬 ERROR: spot.id = \(spot.id ?? "nil"), review.id = \(review.id ?? "nil"). This should not have happend")
            return false
        }
        do {
            let _ = try await dataBase.collection("spots").document(spotID).collection("reviews").document(reviewID).delete()
            print("🗑️ document successfully deleted!")
            return true
        } catch {
            print("🤬 ERROR: removing document \(error.localizedDescription)")
            return false
        }
    }
}
