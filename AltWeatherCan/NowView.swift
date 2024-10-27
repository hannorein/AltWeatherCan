//
//  MainView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import SwiftUI

struct HourlyForecastView: View {
    let hourlyForecast : HourlyForecast
    var body: some View {
        HStack{
            Image(hourlyForecast.iconName)
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing, 5)
            VStack(alignment: .leading){
                Text(hourlyForecast.dateTimeLocal)
                    .font(.footnote)
                Text(String(format:"%.0fºC", hourlyForecast.temperature))
                    .bold()
            }
            .font(.footnote)
        }
        .padding(5)
        .padding( .trailing, 15)
        .background(
            RoundedRectangle(cornerRadius: appCornerRadius)
                .fill(.white)
        )
        
    }
}

struct NowView: View {
    @EnvironmentObject var appManager : AppManager
    var currentTimeZoneShort : String { // There is probably a better way to do this.
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "zzz"
        return dateFormatter2.string(from: Date())
    }
    
    var body: some View {
            ScrollView(.vertical){
                VStack {
                    if let citypage = appManager.citypage {
                        HStack{
                            let currentConditions = citypage.currentConditions
                            Image(currentConditions.iconName)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.trailing, 15)
                            
                            VStack(alignment: .leading){
                                Text(String(format:"%.0fºC", currentConditions.temperature))
                                    .font(.largeTitle)
                                Text(currentConditions.condition)
                                    .bold()
                                Text(String(format:"Wind: \(currentConditions.wind.direction) %.0f km/h", currentConditions.temperature))
                                    .font(.footnote)
                                if let gust = currentConditions.wind.gust {
                                    Text(String(format:"Gusts: %.0f km/h", gust))
                                        .font(.footnote)
                                }
                            }
                        }
                        .padding(.bottom, 35)
                        let hourlyForecast = citypage.hourlyForecastGroup.hourlyForecast
                        ScrollView(.horizontal) {
                            HStack (spacing: 4){
                                ForEach(hourlyForecast) { forecast in
                                    HourlyForecastView(hourlyForecast: forecast)
                                }
                            }
                            .foregroundStyle(.black)
                        }
                        
                        VStack(alignment: .leading){
                            HStack{
                                Image("sunriseWhite18x11")
                                    .colorMultiply(colourIcons)
                                    .frame(width: 16, height: 16)
                                Text("Sunrise - Sunset")
                                Spacer()
                                let sunset = citypage.riseSet.dateTime.first(where: { $0.UTCOffset == 0 && $0.name == "sunset" })
                                let sunrise = citypage.riseSet.dateTime.first(where: { $0.UTCOffset == 0 && $0.name == "sunrise" })
                                if let sunrise, let sunset {
                                    Text("\(sunrise.dateTimeLocal) - \(sunset.dateTimeLocal) \(currentTimeZoneShort)")
                                }
                            }
                            .padding(.top, 5)
                            .padding(.horizontal, 5)
                            Divider()
                                .frame(height:4)
                            HStack{
                                Image("dewpointWhite15x18")
                                    .colorMultiply(colourIcons)
                                    .frame(width: 16, height: 16)
                                Text("Dew point")
                                Spacer()
                                Text(String(format: "%0.fºC", citypage.currentConditions.dewpoint))
                            }
                            .padding(.horizontal, 5)
                            Divider()
                                .frame(height:4)
                            HStack{
                                Image("pressureWhite18x16")
                                    .colorMultiply(colourIcons)
                                    .frame(width: 16, height: 16)
                                Text("Pressure")
                                Spacer()
                                Text(String(format: "%0.1f kPa", citypage.currentConditions.pressure))
                            }
                            .padding(.horizontal, 5)
                            .padding(.bottom, 5)
                        }
                        .foregroundStyle(.black)
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: appCornerRadius)
                                .fill(.white)
                        )
                        
                    } else {
                        Text("No weather data available.")
                    }
                    Spacer()
                    Text("Data Source: Environment and Climate Change Canada")
                        .font(.footnote)
                }
            }
            .refreshable {
                await appManager.refresh()
            }
            .padding(5)
        .background(
            LinearGradient(gradient: Gradient(colors: [colourTop, colourTop, colourBottom]), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    let appManager = AppManager()
    NowView()
        .foregroundStyle(.white)
        .environmentObject(appManager)
    
}
