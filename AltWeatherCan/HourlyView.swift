//
//  HourlyView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//
import SwiftUI

struct HourlyView : View {
    var body: some View {
        HStack{
            Spacer()
            VStack{
                Text("Hourly View")
                Spacer()
                Text("Data Source: Environment and Climate Change Canada")
                    .font(.footnote)
                    .padding(.vertical, 4)

            }
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [colourTop, colourTop, colourBottom]), startPoint: .top, endPoint: .bottom)
        )
    }
}
