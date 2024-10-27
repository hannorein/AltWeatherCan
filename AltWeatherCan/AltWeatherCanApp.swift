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
            TabView {
                NowView()
                    .tabItem {
                        Text("NOW")
                        Image("now24x24")
                            .renderingMode(.template)

                    }
                HourlyView()
                    .tabItem {
                        Text("HOURLY")
                        Image("hourly24x24")
                            .renderingMode(.template)
                    }
                Text("7 Day View")
                    .tabItem {
                        Text("7 DAY")
                        Image("7day24x24")
                            .renderingMode(.template)
                    }
            }
            .accentColor(Color(red: 0.17, green: 0.29, blue: 0.93))
            .onAppear() {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.backgroundColor = .white
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                UITabBar.appearance().standardAppearance = tabBarAppearance
            }
            .environmentObject(appManager)
        }
    }
}
