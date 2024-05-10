//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by Leo  on 11.04.24.
//

import FirebaseFirestoreSwift
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
    //the variable down below does not habe the right path. We change that in .onAppear
    @FirestoreQuery(collectionPath: "spots") var reviews: [Review]
    @State var spot: Spot
    @State private var showPlaceLookupSheet = false
    @State private var showReviewViewSheet = false
    @State private var showSaveAlert = false
    @State private var showingAsSheet = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    let regionSize = 500.0 // meters
    var previewRunning = false
    
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
            .frame(height: 250)
            .onChange(of: spot) { oldValue, newValue in
                annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
                mapRegion.center = spot.coordinate
            }
            
            List {
                Section {
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot: spot, review: review)
                        } label: {
                            SpotReviewRowView(review: review)
                        }
                        
                    }
                } header: {
                    HStack {
                        Text("Avg. Rating:")
                            .font(.title2)
                            .bold()
                        
                        Text("4.5") // TODO: Change this to a computed property
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(Color("SnackColor"))
                        
                        Spacer()
                        
                        Button("Rate It") {
                            if spot.id == nil {
                                showSaveAlert.toggle()
                            } else {
                                showReviewViewSheet.toggle()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .bold()
                        .tint(Color("SnackColor"))
                    }
                }
            }
            .headerProminence(.increased)
            .listStyle(.plain)
            
            Spacer()
        }
        .onAppear {
            if !previewRunning && spot.id != nil { // this is to provide the preview provider error
                $reviews.path = "spots/\(spot.id ?? "")/reviews"
                print("reviews.path = \($reviews.path)")
            } else { // spot.id starts out as nil
                showingAsSheet = true
            }
            
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
            if showingAsSheet { // New spot so showing cancel and save buttons
                if spot.id == nil && showingAsSheet { // New spot so show cancel/save button
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
                } else if showingAsSheet && spot.id != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        }
        .sheet(isPresented: $showReviewViewSheet) {
            NavigationStack {
                ReviewView(spot: spot, review: Review())
            }
        }
        .alert("Cannot Rate Place Unless It Is Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await spotVM.saveSpot(spot: spot)
                    spot = spotVM.spot
                    if success {
                        $reviews.path = "spots/\(spot.id ?? "")/reviews"
                        showReviewViewSheet.toggle()
                    } else {
                        print("🤬 DANG! Error saving spot!")
                    }
                }
            }
        } message: {
            Text("Would you like to save this alert first so that you can enter a review?")
        }
    }
}

#Preview {
    NavigationStack {
        SpotDetailView(spot: Spot(), previewRunning: true)
            .environmentObject(SpotViewModel())
            .environmentObject(LocationManager())
    }
}
