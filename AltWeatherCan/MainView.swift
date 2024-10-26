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
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
        )
        
    }
}

struct MainView: View {
    @EnvironmentObject var appManager : AppManager
    let colourTop = Color(red: 0.16, green: 0.33, blue: 0.66)
    let colourBottom = Color(red: 0.63, green: 0.76, blue: 0.95)
    let colourIcons = Color(red: 0.20, green: 0.30, blue: 0.48)
    var currentTimeZoneShort : String { // There is probably a better way to do this.
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "zzz"
        return dateFormatter2.string(from: Date())
    }
    
    var body: some View {
        HStack{
            Spacer()
            VStack {
                if let citypage = appManager.citypage {
                    let location = citypage.location
                    Text("\(location.name), \(location.province)")
                        .font(.headline)
                        .padding(.bottom, 35)
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
                    let sunset = citypage.riseSet.dateTime.first(where: { $0.UTCOffset == 0 && $0.name == "sunset" })
                    let sunrise = citypage.riseSet.dateTime.first(where: { $0.UTCOffset == 0 && $0.name == "sunrise" })
                       
                    VStack(alignment: .leading){
                        HStack{
                            Image("sunriseWhite18x11")
                                .colorMultiply(colourIcons)
                                .frame(width: 16, height: 16)
                            Text("Sunrise - Sunset")
                            Spacer()
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
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                    )
                    
                } else {
                    Text("No weather data available.")
                }
                Spacer()
                Text("Data Source: Environment and Climate Change Canada")
                    .font(.footnote)
            }
            .foregroundStyle(.white)
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [colourTop, colourTop, colourBottom]), startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    let appManager = AppManager()
    MainView()
        .environmentObject(appManager)
    
}
