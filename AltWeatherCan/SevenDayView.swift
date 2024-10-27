//
//  7DayView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//

import SwiftUI

struct SevenDayView : View {
    var body: some View {
        HStack{
            Spacer()
            VStack{
                Text("Seven Day View")
                Spacer()
                Text("Data Source: Environment and Climate Change Canada")
                    .font(.footnote)
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
