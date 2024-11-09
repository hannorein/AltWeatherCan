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

struct ConditionsRowView : View {
    let imageName : String
    let label : String
    let value : String
    var body: some View {
        HStack{
            Image(imageName)
                .colorMultiply(colourIcons)
                .frame(width: 16, height: 16)
            Text(label)
            Spacer()
            Text(value)
        }
        .padding(.horizontal, 5)
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
            if let citypage = appManager.citypage {
                HStack{
                    if let currentConditions = citypage.currentConditions {
                        if currentConditions.iconCode != 29 {
                            Image(currentConditions.iconName)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.trailing, 15)
                        }else if let iconName = citypage.hourlyForecastGroup.hourlyForecast.first?.iconName{
                            Image(iconName)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.trailing, 15)
                        }
                        
                        VStack(alignment: .leading){
                            if let temperature = currentConditions.temperature {
                                Text(String(format:"%.0fºC", temperature))
                                    .font(.largeTitle)
                            }
                            if let condition = currentConditions.condition{
                                Text(condition)
                                    .bold()
                            }else{
                                Text("Current condition not reported.")
                                    .bold()
                            }
                            if let windChill = currentConditions.windChill {
                                Text(String(format:"Feels like: %.0f km/h", windChill))
                                    .font(.footnote)
                            }
                            if let wind = currentConditions.wind {
                                Text(String(format:"Wind: \(wind.direction) %.0f km/h", wind.speed))
                                    .font(.footnote)
                                if let gust = wind.gust {
                                    Text(String(format:"Gusts: %.0f km/h", gust))
                                        .font(.footnote)
                                }
                            }
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
                
                if let currentConditions = citypage.currentConditions {
                    
                    VStack(alignment: .leading){
                        
                        let sunset = citypage.riseSet.dateTime.first(where: { $0.UTCOffset == 0 && $0.name == "sunset" })
                        let sunrise = citypage.riseSet.dateTime.first(where: { $0.UTCOffset == 0 && $0.name == "sunrise" })
                        if let sunrise, let sunset {
                            let v = "\(sunrise.dateTimeLocal) - \(sunset.dateTimeLocal) \(currentTimeZoneShort)"
                            ConditionsRowView(imageName: "sunriseWhite18x11", label: "Sunrise - Sunset", value: v)
                                .padding(.top, 8)
                        }
                        
                        if let relativeHumidity = currentConditions.relativeHumidity {
                            Divider()
                                .frame(height:4)
                            ConditionsRowView(imageName: "humidityWhite15x18", label: "Humidity", value: String(format: "%0.f%%", relativeHumidity))
                        }
                        
                        if let dewpoint = currentConditions.dewpoint {
                            Divider()
                                .frame(height:4)
                            
                            ConditionsRowView(imageName: "dewpointWhite15x18", label: "Dew point", value: String(format: "%0.fºC", dewpoint))
                        }
                        
                        if let visibility = currentConditions.visibility {
                            Divider()
                                .frame(height:4)
                            ConditionsRowView(imageName: "visibilityWhite18x12", label: "Visibility", value: String(format: "%0.f km", visibility))
                        }
                        
                        if let pressure = currentConditions.pressure {
                            Divider()
                                .frame(height:4)
                            ConditionsRowView(imageName: "pressureWhite18x16", label: "Pressure", value: String(format: "%0.1f kPa", pressure))
                        }
                        
                        Divider()
                            .frame(height:4)
                        HStack{
                            if let dateTime = currentConditions.dateTime.first(where: { $0.UTCOffset != 0 } ) {
                                if let station = currentConditions.station {
                                    Text("Observed at: \(station)\n\(dateTime.textSummary)")
                                }
                            }
                            Spacer()
                        }
                        .font(.caption2)
                        .padding(.leading, 4)
                        .padding(.bottom, 5)
                    }
                    .foregroundStyle(.black)
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: appCornerRadius)
                            .fill(.white)
                    )
                }
                Spacer()
                Text("Data Source: Environment and Climate Change Canada")
                    .font(.footnote)
                    .padding(.top, 40)
                    .padding(.bottom, 4)
            } else {
                Text("No weather data available.")
                    .frame(maxWidth: .infinity)
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
