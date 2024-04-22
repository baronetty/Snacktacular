//
//  ContentView.swift
//  PlaceLookupDemo
//
//  Created by Leo  on 15.04.24.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var showPlaceLookUpSheet = false
    @State var returnedPlace = Place(mapItem: MKMapItem())
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Location:\n\(locationManager.location?.coordinate.latitude ?? 0.0), \(locationManager.location?.coordinate.longitude ?? 0.0)")
                    .padding(.bottom)
                
                Text("Returned Place: \nName: \(returnedPlace.name)\nAddress: \(returnedPlace.address)\nCoords: \(returnedPlace.latitude), \(returnedPlace.longitude)")
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showPlaceLookUpSheet.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                        Text("Lookup Place")
                    }
                }
            }
            .fullScreenCover(isPresented: $showPlaceLookUpSheet) {
                PlaceLookupView(returnedPlace: $returnedPlace)
            }
        }
    }
}

#Preview {
    ContentView() // Location doesn't show in Live Preview -  use Simulator
        .environmentObject(LocationManager())
}
