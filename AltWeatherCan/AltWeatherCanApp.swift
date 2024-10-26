//
//  AltWeatherCanApp.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import SwiftUI

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
