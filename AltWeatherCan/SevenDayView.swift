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
        
        if let citypage = appManager.citypage {
            var forecasts = citypage.forecastGroup.forecast
            if let first = forecasts.first {
                if first.period.localizedCaseInsensitiveContains("night"){
                    forecasts.insert(Forecast(period: first.period.replacingOccurrences(of: " night", with: ""), textSummary: "", abbreviatedForecast: AbbreviatedForecast(iconCode: 29, textSummary: ""), temperatures: Temperatures(temperature: Double.nan, textSummary: "-")), at: 0)
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
                        if let issueDate = citypage.forecastGroup.dateTime.first(where: { $0.UTCOffset != 0 }) {
                            Text("Issued at: \(issueDate.textSummary)")
                                .font(.caption2)
                                .frame(maxWidth:.infinity, alignment: .leading)
                                .foregroundStyle(.white)
                        }
                        let columns = [GridItem(.flexible())]
                        
                        ScrollView(.horizontal) {
                            let rows = [GridItem(.fixed(20), spacing: 1), GridItem(.fixed(110), spacing: 1), GridItem(.fixed(110), spacing: 1)]
                            
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
                                        }else{
                                            Text("-")
                                                .frame(width:40, height: 60)
                                        }
                                        Spacer()
                                    }
                                    .frame(maxWidth:.infinity, maxHeight:.infinity)
                                    .font(.callout)
                                    .background(.white)
                                }
                            }
                        }
                        .frame(height:242)
                        .foregroundStyle(.black)
                        .clipShape(
                            RoundedRectangle(cornerRadius: appCornerRadius)
                        )
                        
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
