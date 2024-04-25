//
//  PlaceLookupView.swift
//  PlaceLookupDemo
//
//  Created by Leo  on 16.04.24.
//

import MapKit
import SwiftUI


struct PlaceLookupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @Binding var spot: Spot
    @State private var searchText = ""
    @StateObject var placeVM = PlaceViewModel()
    
    var body: some View {
        NavigationStack {
            List(placeVM.places) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.title2)
                    Text(place.address)
                        .font(.callout)
                }
                .onTapGesture {
                    spot.name = place.name
                    spot.address = place.address
                    spot.latitude = place.latitude
                    spot.longitude = place.longitude
                    dismiss()
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .onChange(of: searchText) { text, oldValue in
                if !text.isEmpty {
                    placeVM.search(text: text, region: locationManager.region)
                } else {
                    placeVM.places = []
                }
            }
            .toolbar  {
                ToolbarItem(placement: .automatic) {
                    Button {
                        dismiss()
                    } label: {
                        Text("cancel")
                    }
                }
            }
        }
    }
}

#Preview {
    PlaceLookupView(spot: .constant(Spot()))
        .environmentObject(LocationManager())
}
