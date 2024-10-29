//
//  MainView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//

import SwiftUI

struct MainView : View {
    @EnvironmentObject var appManager : AppManager
    @State var locationScreenShown : Bool = false
    var body: some View {
        VStack{
            if let citypage = appManager.citypage {
                
                HStack{
                    Text("\(citypage.location.name), \(citypage.location.province.code.uppercased())")
                        .font(.title)
                    Image("search25x25")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .onTapGesture {
                    locationScreenShown.toggle()
                }
                ForEach(citypage.warnings.event) { event in
                    let type = event.type.lowercased()
                    Link(destination: URL(string: event.url)!) {
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
            }else{
                HStack{
                    Text("No location selected")
                        .font(.title)
                    Image("search25x25")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .onTapGesture {
                    locationScreenShown.toggle()
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
                AboutView()
                    .tabItem {
                        Text("ABOUT")
                        Image("outline_info_black_24pt24x24")
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
        .fullScreenCover(isPresented: $locationScreenShown) {
            LocationView(locationScreenShown: $locationScreenShown)
        }
    }
}

#Preview {
    let appManager = AppManager()
    MainView()
        .environmentObject(appManager)
    
}

