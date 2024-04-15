//
//  ListView.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import Firebase
import FirebaseFirestoreSwift
import SwiftUI

struct ListView: View {
    @Environment(\.dismiss) private var dismiss
    @FirestoreQuery(collectionPath: "spots") var spots: [Spot]
    @State private var sheetIsPresented = false
    
    var body: some View {
        NavigationStack {
            List(spots) { spot in
                NavigationLink {
                    SpotDetailView(spot: spot)
                } label: {
                    Text(spot.name)
                        .font(.title2)
                }
                
            }
            .listStyle(.plain)
            .navigationTitle("Snack Spots")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("🪵➡️ Log out successful")
                            dismiss()
                        } catch {
                            print("🤬 ERROR: could not sign out")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        sheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }
            }
            .sheet(isPresented: $sheetIsPresented) {
                NavigationStack {
                    SpotDetailView(spot: Spot())
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ListView()
    }
}
