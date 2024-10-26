//
//  ContentView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import SwiftUI

struct ContentView: View {
    @State var citypage = Citypage.load()
    let colourTop = Color(red: 0.16, green: 0.33, blue: 0.66)
    let colourBottom = Color(red: 0.63, green: 0.76, blue: 0.95)

    var body: some View {
        HStack{
            Spacer()
            VStack {
                if let citypage {
                    
                    
                    if let location = citypage.location {
                        Text(location.name)
                            .font(.headline)
                            .padding(.bottom, 15)
                    }
                    HStack{
                        if let currentConditions = citypage.currentConditions {
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
                                Text(String(format:"Gusts: %.0f km/h", currentConditions.wind.gust))
                                    .font(.footnote)
                                
                            }
                        }
                    }
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
    ContentView()
}
