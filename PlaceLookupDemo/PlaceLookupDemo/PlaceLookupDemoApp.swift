//
//  PlaceLookupDemoApp.swift
//  PlaceLookupDemo
//
//  Created by Leo  on 15.04.24.
//

import SwiftUI

@main
struct PlaceLookupDemoApp: App {
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}
