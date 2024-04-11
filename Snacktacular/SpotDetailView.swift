//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import SwiftUI

struct SpotDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var spotVM: SpotViewModel
    @State var spot: Spot
    
    var body: some View {
        VStack {
            Group {
                TextField("Name", text: $spot.name)
                    .font(.title)
                TextField("Address", text: $spot.address)
                    .font(.title2)
            }
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(spot.id == nil)
        .toolbar {
            if spot.id == nil { // New spot so show cancel/save button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await spotVM.saveSpot(spot: spot)
                            
                            if success {
                                dismiss()
                            } else {
                                print("🤬 ERROR: saving spot")
                            }
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SpotDetailView(spot: Spot())
            .environmentObject(SpotViewModel())
    }
}
