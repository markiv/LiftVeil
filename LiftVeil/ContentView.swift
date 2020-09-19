//
//  ContentView.swift
//  LiftVeil
//
//  Created by Vikram Kriplaney on 19.09.2020.
//

import AVKit
import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject var locationModel = LocationModel.shared
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "movie", withExtension: "mp4")!)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var location: CLLocation?
    @State var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(),
                                              latitudinalMeters: 500, longitudinalMeters: 500)

    var map: some View {
        Map(coordinateRegion: $mapRegion, showsUserLocation: true)
            .animation(.default)
            .id("map")
    }

    var movie: some View {
        VideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Lift the Veil")
            .id("movie")
    }

    var body: some View {
        GeometryReader { geometry in
            // Thank you, Swift 5.3, for letting me do this:
            let isPortrait = geometry.size.width < geometry.size.height
            
            NavigationView {
                if isPortrait {
                    // In portrait mode, stack the movie and map vertically
                    VStack(spacing: 0) {
                        movie
                        map
                    }.edgesIgnoringSafeArea(.bottom)
                } else {
                    // In landscape mode, overlay the map on the movie
                    ZStack(alignment: .topLeading) {
                        movie
                            .edgesIgnoringSafeArea(.all)
                        map
                            .frame(width: geometry.size.width / 4, height: geometry.size.height / 3)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                    }
                }
            }
            .onReceive(locationModel.$location) { location in
                if let location = location {
                    // Update map position
                    mapRegion = MKCoordinateRegion(
                        center: location.coordinate,
                        latitudinalMeters: 400, longitudinalMeters: 400
                    )
                    // TODO: Find nearest waypoint in GPX, then
                    // - Seek movie to corresponding timestamp
                    // - Adjust player rate to match real current speed
                }
            }
            .onAppear {
                player.play()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
