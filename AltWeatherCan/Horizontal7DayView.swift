//
//  Horizontal7DayView.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-03-27.
//

import Foundation
import SwiftUI

struct Horizontal7DayView: View {
    var forecastGroup : ForecastGroup?
    
    private func forecastsCleaned () -> [Forecast] {
        if let forecastGroup {
            var forecasts = forecastGroup.forecast
            if let first = forecasts.first {
                if first.period.localizedCaseInsensitiveContains("night"){
                    forecasts.insert(Forecast(period: first.period.replacingOccurrences(of: " night", with: ""), textSummary: "", abbreviatedForecast: AbbreviatedForecast(), temperatures: Temperatures(temperature: Double.nan, textSummary: "-"), windChill: nil), at: 0)
                }
            }
            return forecasts
        } else {
            return []
        }
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            let rows = [GridItem(.fixed(20), spacing: 1), GridItem(.fixed(115), spacing: 1), GridItem(.fixed(115), spacing: 1)]
            
            LazyHGrid(rows: rows, spacing: 1) {
                ForEach(Array(forecastsCleaned().enumerated()), id: \.offset) { index, forecast in
                    if index % 2 == 0 {
                        Text(forecast.period)
                            .frame(width:100, height: 20)
                            .font(.footnote)
                            .background(.white)
                    }
                    VStack{
                        Text(index % 2 == 0 ? "Day" : "Night")
                            .font(.footnote)
                            .padding(.top, 4)
                        if (forecast.temperatures.temperature.isFinite){ // If first forecast is night
                            Image(forecast.abbreviatedForecast.iconName)
                                .resizable()
                                .frame(width:40, height: 40)
                            Text(String(format: "%.0fºC", forecast.temperatures.temperature))
                            if let pop = forecast.abbreviatedForecast.pop {
                                Text(String(format: "%.0f%%", pop))
                                    .font(.caption2)
                            }
                        }else{
                            Spacer()
                                .frame(width: 40, height: 40)
                            Text("---")
                            
                        }
                        Spacer()
                    }
                    .frame(maxWidth:.infinity, maxHeight:.infinity)
                    .font(.callout)
                    .background(.white)
                }
            }
        }
        .frame(height:252)
        .foregroundStyle(.black)
        .clipShape(
            RoundedRectangle(cornerRadius: appCornerRadius)
        )
    }
}

#Preview {
    @Previewable @State var forecastGroup : ForecastGroup? = nil
    Horizontal7DayView(forecastGroup: forecastGroup)
        .foregroundStyle(.white)
        .task {
            do {
                let site = Site(code: "s0000627", name: "Inukjuak", province: "QC", latitude: 43.74, longitude: 79.37, distance: nil)
                let dataDownloader = DataDownloader()
                let newCitypage = try await dataDownloader.getCitypage(site: site)
                forecastGroup = newCitypage.forecastGroup
            } catch {
                print("download error: \(error)")
            }
        }
}
