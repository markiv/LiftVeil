//
//  ContentView.swift
//  LiftVeil
//
//  Created by Vikram Kriplaney <vikram@iphonso.ch> on 19.09.2020.
//  Copyright © 2020 iPhonso GmbH. All rights reserved.
//

import AVKit
import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject var locationModel = LocationModel.shared
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "movie", withExtension: "mp4")!)
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(),
        latitudinalMeters: 500, longitudinalMeters: 500
    )
    @State private var nearestSignal: Signal?

    var map: some View {
        Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: TrackData.site.signals) { signal in
            MapAnnotation(coordinate: signal.location?.coordinate ?? CLLocationCoordinate2D(), anchorPoint: CGPoint(x: 0.5, y: 1)) {
                if signal.elementType.contains("istant") {
                    Image("distantsignal").foregroundColor(.red)
                } else {
                    Image("mainsignal").foregroundColor(.green)
                }
            }
        }
        .animation(.default)
        .id("map")
    }

    var movie: some View {
        ZStack(alignment: .topTrailing) {
            VideoPlayer(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Lift the Veil")
            hud
        }.id("movie")
    }

    @ViewBuilder var hud: some View {
        if let signal = nearestSignal {
            VStack(alignment: .trailing) {
                Text(signal.locationName).bold()
                Text(signal.elementType)
                if
                    let signalLocation = signal.location,
                    let distance = locationModel.location?.distance(from: signalLocation)
                {
                    Text("\(distance: distance)")
                }
            }
            .font(.largeTitle)
            .foregroundColor(.white)
            .shadow(color: .black, radius: 1)
            .padding()
        }
    }

    var body: some View {
        GeometryReader { geometry in
            // Thank you, Swift 5.3, for letting me do this:
            let isPortrait = geometry.size.width < geometry.size.height

            if isPortrait {
                // In portrait mode, stack the movie and map vertically
                VStack(spacing: 0) {
                    movie
                    map
                }.edgesIgnoringSafeArea(.bottom)
            } else {
                // In landscape mode, overlay the map on the movie
                ZStack(alignment: .bottomLeading) {
                    movie
                        .edgesIgnoringSafeArea(.all)
                    map
                        .frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
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
                //  Find nearest waypoint in GPX
                nearestSignal = TrackData.site.nearest(to: location)

                // TODO:
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

extension LocalizedStringKey.StringInterpolation {
    private static let distanceFormatter: MKDistanceFormatter = {
        let this = MKDistanceFormatter()
        this.unitStyle = .abbreviated
        return this
    }()

    mutating func appendInterpolation(distance: CLLocationDistance) {
        appendInterpolation(
            Self.distanceFormatter.string(fromDistance: distance)
        )
    }
}

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
#endif
