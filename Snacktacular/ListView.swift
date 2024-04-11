//
//  ListView.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import Firebase
import SwiftUI

struct ListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sheetIsPresented = false
    
    var body: some View {
        List {
            Text("List items will go here")
        }
        .listStyle(.plain)
        .navigationBarBackButtonHidden()
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

#Preview {
    NavigationStack {
        ListView()
    }
}
