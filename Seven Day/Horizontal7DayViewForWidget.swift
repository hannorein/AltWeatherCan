//
//  Horizontal7DayView.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-03-27.
//

import Foundation
import SwiftUI
import WidgetKit

struct Horizontal7DayViewForWidget: View {
    var forecastGroup : ForecastGroup?
    var site : Site?
    private func forecastsCleaned () -> [Forecast] {
        if let forecastGroup {
            var forecasts = forecastGroup.forecast
            if let first = forecasts.first {
                if first.period.localizedCaseInsensitiveContains("night"){
                    forecasts.insert(Forecast(period: first.period.replacingOccurrences(of: " night", with: ""), textSummary: "", abbreviatedForecast: AbbreviatedForecast(), temperatures: Temperatures(temperature: Double.nan, textSummary: "-"), windChill: nil), at: 0)
                    forecasts.insert(Forecast(period: first.period.replacingOccurrences(of: " night", with: ""), textSummary: "", abbreviatedForecast: AbbreviatedForecast(), temperatures: Temperatures(temperature: Double.nan, textSummary: "-"), windChill: nil), at: forecasts.endIndex)
                }
            }
            return forecasts
        } else {
            return []
        }
    }
    
    var body: some View {
        let rows = [GridItem(.fixed(20),spacing: 0), GridItem(.fixed(65),spacing: 0), GridItem(.fixed(65),spacing: 0)]
        
        
        if forecastGroup == nil{
            Text("Loading...")
        }else{
            VStack(spacing: 0) {
                if let site {
                    Text(site.name)
                        .font(.caption2)
                        .fixedSize()
                        .frame(height: 4)
                        .padding(.top, 5)
                        .opacity(0.8)
                }
                LazyHGrid(rows: rows, spacing: 1) {
                    ForEach(Array(forecastsCleaned().enumerated()), id: \.offset) { index, forecast in
                        if index % 2 == 0 {
                            Text(forecast.period.prefix(3))
                                .frame(width:47, height: 20)
                        }
                        VStack{
                            Divider()
                            if (forecast.temperatures.temperature.isFinite){ // If first forecast is night
                                Image(forecast.abbreviatedForecast.iconName)
                                    .resizable()
                                    .frame(width:30, height: 30)
                                Text(String(format: "%.0fºC", forecast.temperatures.temperature))
                                    .font(.callout)
                            }else{
                                Spacer()
                            }
                        }
                        .background(.background)
                    }
                }
                .font(.caption2)
            }
        }
    }
}


#Preview(as: .systemMedium) {
    Seven_Day()
} timeline: {
    let dataDownloader = DataDownloader()
    let citypage = dataDownloader.getDummyCitypage()
    let forecastGroup = citypage.forecastGroup
    let site = Site(code: "s0000630", name: "Default", province: "ON", latitude: 43.74, longitude: 79.37, distance: nil)
    let myIntent = ConfigurationAppIntent()
    myIntent.site = site
    return [
        SimpleEntry(date: .now, forecastGroup: forecastGroup, configuration: myIntent)
        ]
}
