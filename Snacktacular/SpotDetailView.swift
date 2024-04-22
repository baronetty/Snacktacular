//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import MapKit
import SwiftUI

struct SpotDetailView: View {
    struct Annotation: Identifiable {
        let id = UUID()
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var spotVM: SpotViewModel
    @State var spot: Spot
    @State private var showPlaceLookupSheet = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    let regionSize = 500.0 // meters
    
    var body: some View {
        VStack {
            Group {
                TextField("Name", text: $spot.name)
                    .font(.title)
                TextField("Address", text: $spot.address)
                    .font(.title2)
            }
            .disabled(spot.id == nil ? false : true)
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: spot.id == nil ? 2 : 0)
            }
            .padding(.horizontal)
            
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            }
            .onChange(of: spot) { oldValue, newValue in
                annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
                mapRegion.center = spot.coordinate
            }
            
            Spacer()
        }
        .onAppear {
            if spot.id != nil { // if we habe a spot, center the spot
                mapRegion = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
            } else { // otherwise center the map on the device location
                Task { // If you don't embed in a task, the map update likely won't show
                    mapRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                }
            }
            annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
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
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showPlaceLookupSheet.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                        Text("Lookup Place")
                    }

                }
            }
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        }
    }
}

#Preview {
    NavigationStack {
        SpotDetailView(spot: Spot())
            .environmentObject(SpotViewModel())
            .environmentObject(LocationManager())
    }
}
