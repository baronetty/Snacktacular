//
//  SpotViewModel.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit

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
    
    func saveImage(spot: Spot, photo: Photo, image: UIImage) async -> Bool {
        guard let spotID = spot.id else {
            print("🤬 ERROR: spot.id == nil")
            return false
        }
        
        let photoName = UUID().uuidString // name of image file
        let storage = Storage.storage() // create a Firebase Storage instance
        let storageRef = storage.reference().child("\(spotID)/\(photoName).jpeg")
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.2) else {
            print("🤬 ERROR: could not resize image")
            return false
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" // setting metadata allows you to see console image in the web browser
        
        var imageURLString = "" // We'll see this after the image is succesfulls saved
        
        do {
            let _ = try await storageRef.putDataAsync(resizedImage, metadata: metadata)
            print("📸 Image Saved!")
            do {
                let imageURL = try await storageRef.downloadURL()
                imageURLString = "\(imageURL)" // We'll save this to cloud firestore as part of document 'photos' collection below
            } catch {
                print("🤬 ERROR: could not get imageURL after saving image \(error.localizedDescription)")
                return false
            }
        } catch {
            print("🤬 ERROR: uploading image to firebase storage.")
            return false
        }
        
        // Now save to the 'photos' collection of the spot document "spotID"
        let dataBase = Firestore.firestore()
        let collectionString = "spots/\(spotID)/photos"
        
        do {
            var newPhoto = photo
            newPhoto.imageURLString = imageURLString
            try await dataBase.collection(collectionString).document(photoName).setData(newPhoto.dictionary)
            print("😎 data updated succsessfully.")
            return true
        } catch {
            print("🤬 ERROR: could not update data in 'photos' for spotID \(spotID).")
            return false
        }
    }
}
