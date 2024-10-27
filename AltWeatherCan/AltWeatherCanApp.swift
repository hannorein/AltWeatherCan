//
//  AltWeatherCanApp.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import SwiftUI


let colourTop = Color(red: 0.16, green: 0.33, blue: 0.66)
let colourBottom = Color(red: 0.63, green: 0.76, blue: 0.95)
let colourIcons = Color(red: 0.20, green: 0.30, blue: 0.48)
let appCornerRadius : CGFloat = 5

@main
struct AltWeatherCanApp: App {
    @StateObject var appManager = AppManager()
    var body: some Scene {
        WindowGroup {
            MainView()
            .environmentObject(appManager)
        }
    }
}

