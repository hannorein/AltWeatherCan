//
//  AboutView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//
import SwiftUI

struct AboutView : View {
    var body: some View {
        HStack{
            Spacer()
            VStack{
                ScrollView(.vertical) {
                    let columns = [GridItem(.flexible())]

                    LazyVGrid(columns: columns, spacing: 1) {
                        TitleRow(title: "About this app")
                        TextRow(text: "This app has been created by Hanno Rein. Its purpose is to provide a simple and intuitive way to view weather information for your location. The functionality and design tries to replicate the \"old\" WeatherCan App that was developed by Environment and Climate Change Canada (ECCC). The development of this alternative app was triggered by the redesign of the WeatherCan App in October 2024 which significantly reduced readability due to a low contrast colour scheme and a reduced information density. Not all features found in the original WeatherCan App have been replicated yet.")
                        TextRow(text: "This app uses publicly available data provided by Environment and Climate Change Canada (ECCC). However the app is not affiliated with or endorsed by ECCC in any way. The use of this app is at your own risk. The developers and associated parties are not responsible for any damages, losses, or negative consequences that may arise from your use of the app. We make no guarantees regarding the accuracy, reliability, or completeness of the information provided. By using this app, you acknowledge and agree that you will not hold the developers liable for any issues that may occur.")
                        Link(destination: URL(string: "https://github.com/hannorein/altweathercan")!){
                            TextRow(text: "The source code of this app is freely available on GitHub at https://github.com/hannorein/altweathercan. Bug reports and contributions are welcome.")
                        }
                        
                    }
                }
            }
            .foregroundStyle(.black)
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [colourTop, colourTop, colourBottom]), startPoint: .top, endPoint: .bottom)
        )
    }
}


#Preview {
    AboutView()
        .foregroundStyle(.white)
}

struct TitleRow: View {
    var title : String
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(height: 4)
            .padding(0)
        HStack{
            Text(title)
                .padding(5)
                .font(.footnote)
                .bold()
            Spacer()
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        Rectangle()
            .fill(.clear)
            .frame(height: 1)
            .padding(0)
    }
}

struct TextRow: View {
    var text : String
    var body: some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .padding(6)
            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .leading)
            .font(.footnote)
            .background(Color.white)
    }
}
