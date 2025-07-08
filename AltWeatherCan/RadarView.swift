//
//  HourlyView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//
import SwiftUI

struct RadarView : View {
    @EnvironmentObject var appManager : AppManager

    var body: some View {
        HStack{
            Spacer()
            VStack{
                if let radarStation = appManager.selectedSite.closestRadarStation {
                    ScrollView(.vertical) {
                        AsyncImage(url: appManager.latestRadarImageURL){ image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Text("Radar for \(radarStation.region), \(radarStation.province) (\(radarStation.name)).")
                    }
                    .refreshable {
                        await appManager.refresh()
                    }
                    
                    
                    Spacer()
                    Text("Data Source: Environment and Climate Change Canada")
                        .font(.footnote)
                        .padding(.vertical, 4)
                } else{
                    Text("No data available.")
                    Spacer()
                }
            }
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [colourTop, colourTop, colourBottom]), startPoint: .top, endPoint: .bottom)
        )
    }
}


#Preview {
    let appManager = AppManager()
    RadarView()
        .foregroundStyle(.white)
        .environmentObject(appManager)
    
}
