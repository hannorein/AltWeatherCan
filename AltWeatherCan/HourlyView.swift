//
//  HourlyView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//
import SwiftUI

struct HourlyView : View {
    @EnvironmentObject var appManager : AppManager

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
                        
                        
                        
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(Array(citypage.hourlyForecastGroup.hourlyForecast.enumerated()), id: \.offset) { index, forecast in
                                if index == 0 || forecast.dateTimeNewDay {
                                    TitleRow(title: forecast.dateTimeLocal2)
                                }
                                VStack{
                                    HStack{
                                        Text(forecast.dateTimeLocal)
                                            .frame(width:40, alignment: .leading)
                                        VStack {
                                            Image(forecast.iconName)
                                                .resizable()
                                                .frame(width:30, height: 30)
                                                .padding(.trailing, 8)
                                            Text(String(format: "%.0f%%", forecast.lop))
                                        }
                                        Text(String(format: "%.0fºC", forecast.temperature))
                                            .frame(width:40, alignment: .leading)
                                            .bold()
                                        VStack (alignment: .leading){
                                            Text(forecast.condition)
                                            if let humidex = forecast.humidex {
                                                Text("Feels like: ").bold() + Text(String(format: " %.0fºC", humidex))
                                            }else if let windChill = forecast.windChill {
                                                Text("Feels like: ").bold() + Text(String(format: " %.0fºC", windChill))
                                            }
                                            Text("Wind: ").bold() + Text(forecast.wind.direction) + Text(String(format: " %.0f km/h", forecast.wind.speed))
                                            if let gust = forecast.wind.gust {
                                                Text("Gust: ").bold() + Text(String(format: " %.0f km/h", gust))
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                                .padding(6)
                                .frame(maxWidth:.infinity, maxHeight:.infinity)
                                .font(.footnote)
                                .background(forecast.isNight ? Color.init(white: 0.90) : Color.white)
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
    HourlyView()
        .foregroundStyle(.white)
        .environmentObject(appManager)
    
}
