//
//  7DayView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//

import SwiftUI

struct SevenDayView : View {
    @EnvironmentObject var appManager : AppManager

    var body: some View {
        HStack{
            Spacer()
            VStack{
                if let citypage = appManager.citypage {
                    if let issueDate = citypage.forecastGroup.dateTime.first(where: { $0.UTCOffset != 0 }) {
                        Text("Issued at: \(issueDate.textSummary)")
                            .font(.caption2)
                            .frame(maxWidth:.infinity, alignment: .leading)
                    }
                    ScrollView(.horizontal) {
                        let rows = [GridItem(.fixed(20), spacing: 1), GridItem(.fixed(110), spacing: 1), GridItem(.fixed(110), spacing: 1)]
                        
                        LazyHGrid(rows: rows, spacing: 1) {
                            ForEach(Array(citypage.forecastGroup.forecast.enumerated()), id: \.offset) { index, forecast in
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
                                    Image(forecast.abbreviatedForecast.iconName)
                                        .resizable()
                                        .frame(width:40, height: 40)
                                    Text(String(format: "%.0fºC", forecast.temperatures.temperature))
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
                    ScrollView(.vertical) {
                        let columns = [GridItem(.flexible())]

                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(Array(citypage.forecastGroup.forecast.enumerated()), id: \.offset) { index, forecast in
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
                            }
                        }
                    }
                    .foregroundStyle(.black)
                    .clipShape(
                        RoundedRectangle(cornerRadius: appCornerRadius)
                    )
                    Spacer()
                    Text("Data Source: Environment and Climate Change Canada")
                        .font(.footnote)
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
