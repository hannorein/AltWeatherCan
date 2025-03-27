//
//  7DayView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//

import SwiftUI

struct SevenDayView : View {
    @EnvironmentObject var appManager : AppManager
    
    private func forecastsCleaned () -> [Forecast] {
        if let forecastGroup = appManager.citypage?.forecastGroup {
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
        HStack{
            Spacer()
            VStack{
                if let citypage = appManager.citypage {
                    ScrollView(.vertical) {
                        if appManager.citypage?.forecastGroup?.forecast.count == 0 {
                            Text("No forecast available.")
                                .foregroundStyle(.white)
                        }
                        if let issueDate = citypage.forecastGroup?.dateTime.first(where: { $0.UTCOffset != 0 }) {
                            Text("Issued at: \(issueDate.textSummary)")
                                .font(.caption2)
                                .frame(maxWidth:.infinity, alignment: .leading)
                                .foregroundStyle(.white)
                        }
                        
                        ScrollView(.horizontal) {
                            Horizontal7DayView(forecastGroup: appManager.citypage?.forecastGroup)
                                .frame(height:252)
                                .foregroundStyle(.black)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: appCornerRadius)
                                )
                        }
                        
                        let columns = [GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(Array(forecastsCleaned().enumerated()), id: \.offset) { index, forecast in
                                if index % 2 == 0 {
                                    HStack{
                                        Text(forecast.period)
                                            .padding(5)
                                            .font(.footnote)
                                            .bold()
                                        Spacer()
                                    }
                                    .background(.white)
                                }
                                if (forecast.temperatures.temperature.isFinite){ // Skip if first forecast is night
                                    VStack(spacing: 2){
                                        VStack{
                                            HStack{
                                                Text(index % 2 == 0 ? "Day" : "Night")
                                                    .frame(width:40, alignment: .leading)
                                                Image(forecast.abbreviatedForecast.iconName)
                                                    .resizable()
                                                    .frame(width:30, height: 30)
                                                    .padding(.trailing, 26)
                                                Text(String(format: "%.0fºC", forecast.temperatures.temperature))
                                                    .frame(alignment: .leading)
                                                Spacer()
                                            }
                                            Text(forecast.textSummary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(6)
                                        .frame(maxWidth:.infinity, maxHeight:.infinity)
                                        .font(.footnote)
                                        .background(index % 2 == 0 ? .white : .init(white: 0.90))
                                        if index % 2 == 1 {
                                            Rectangle()
                                                .fill(.clear)
                                                .frame(height: 1)
                                                .padding(0)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .foregroundStyle(.black)
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
    SevenDayView()
        .foregroundStyle(.white)
        .environmentObject(appManager)
    
}

