//
//  ContentView.swift
//  PlaceLookupDemo
//
//  Created by Leo  on 15.04.24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Location:\n\(locationManager.location?.coordinate.latitude ?? 0.0), \(locationManager.location?.coordinate.longitude ?? 0.0)")
                .padding(.bottom)
        }
        .padding()
    }
}

#Preview {
    ContentView() // Location doesn't show in Live Preview -  use Simulator
        .environmentObject(LocationManager())
}
