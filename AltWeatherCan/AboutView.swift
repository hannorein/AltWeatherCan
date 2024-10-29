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
                        TextRow(text: "This app has been created by Hanno Rein.")
                        TextRow(text: "dd")
                        TextRow(text: "dd")
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
            .padding(6)
            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .leading)
            .font(.footnote)
            .background(Color.white)
    }
}
