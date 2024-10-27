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

                ScrollView(.horizontal){
                    ScrollView(.horizontal) {
                        let rows = [GridItem(.fixed(20), spacing: 1), GridItem(.fixed(100), spacing: 1), GridItem(.fixed(100), spacing: 1)]

                        LazyHGrid(rows: rows, spacing: 1) {
                            ForEach(Array(citypage.forecastGroup.forecast.enumerated()), id: \.offset) { index, forecast in
                                if index % 2 == 0 {
                                    Text(forecast.period)
                                        .padding(.horizontal)
                                        .frame(maxWidth:.infinity, maxHeight:.infinity)
                                        .font(.callout)
                                        .background(.white)
                                }
                                VStack{
                                    Text(index % 2 == 0 ? "Day" : "Night")
                                        .font(.footnote)
                                    Image(forecast.abbreviatedForecast.iconName)
                                        .resizable()
                                        .frame(width:40, height: 40)
                                    Text(String(format: "%.0fºC", forecast.temperatures.temperature))
                                }
                                .frame(maxWidth:.infinity, maxHeight:.infinity)
                                .font(.callout)
                                .background(.white)
                            }
                        }
                    }
                }
                .frame(height:223)
                .foregroundStyle(.black)
                .clipShape(
                    RoundedRectangle(cornerRadius: 4)
//                        .fill(.white)
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
