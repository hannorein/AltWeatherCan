//
//  MainView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//

import SwiftUI

struct MainView : View {
    @EnvironmentObject var appManager : AppManager

    var body: some View {
        VStack{
            if let citypage = appManager.citypage {
                
                Text("\(citypage.location.name), \(citypage.location.province)")
                    .font(.headline)
                ForEach(citypage.warnings.event) { event in
                    let type = event.type.lowercased()
                    HStack {
                        Image("warningTriangle24x24")
                        Spacer()
                        Text(event.description.capitalized)
                        Spacer()
                        Image("detailDisclosure25x25")
                            .colorInvert()
                    }
                    .padding(5)
                    .background( type == "warning" ? .red : (type == "watch" ? .yellow : .gray))
                }
            }
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
                SevenDayView()
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
        }
        .foregroundStyle(.white)
        .background(colourTop)
    }
}

#Preview {
    let appManager = AppManager()
    MainView()
        .environmentObject(appManager)
    
}

