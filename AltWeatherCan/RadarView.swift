//
//  HourlyView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//
import SwiftUI

struct RadarView : View {
    @EnvironmentObject var appManager : AppManager
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0 // Stores scale after gesture ends
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero // Stores offset after gesture ends
    //    init() {
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    //        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.accentColor)
    //        UISegmentedControl.appearance().backgroundColor = UIColor.clear // Overall background color
    //    }
    
    var body: some View {
        HStack{
            Spacer()
            VStack{
                if let radarStation = appManager.selectedSite.closestRadarStation {
                    ScrollView(.vertical) {
                        Text("Radar for \(radarStation.region) (\(radarStation.name)).")
                        if let imageURL = appManager.latestRadarImageURL {
                            AsyncImage(url: imageURL){ phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .scaleEffect(currentScale)
                                        .offset(currentOffset)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    currentOffset = CGSize(
                                                        width: finalOffset.width + value.translation.width,
                                                        height: finalOffset.height + value.translation.height)
                                                }
                                                .onEnded { value in
                                                    finalOffset = currentOffset
                                                    // Optional: Reset offset if zoomed out
                                                    if finalScale == 1.0 {
                                                        finalOffset = .zero
                                                        currentOffset = .zero
                                                    }
                                                }
                                        )
                                        .gesture(
                                            MagnificationGesture()
                                                .onChanged { scale in
                                                    currentScale = finalScale * scale
                                                }
                                                .onEnded { scale in
                                                    finalScale = currentScale
                                                    // Optional: Limit zoom out to prevent tiny image
                                                    if finalScale < 1.0 {
                                                        finalScale = 1.0
                                                        currentScale = 1.0
                                                        // Reset offset if completely zoomed out
                                                        finalOffset = .zero
                                                        currentOffset = .zero
                                                    }
                                                }
                                        )
                                        .clipped()
                                        .contentShape(Rectangle())
                                case .failure:
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .aspectRatio(580.0/480.0, contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .overlay {
                                            Label("An error occurred while downloading the radar image.", systemImage:"exclamationmark.icloud.fill")
                                                .padding()
                                        }
                                default:
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .aspectRatio(580.0/480.0, contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .overlay {
                                            VStack{
                                                ProgressView()
                                                    .tint(.white)
                                                Text("Loading radar image...")
                                            }
                                        }
                                }
                            }
                            
                        }else{
                            Rectangle()
                                .foregroundStyle(.clear)
                                .aspectRatio(580.0/480.0, contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .overlay {
                                    Label("No radar image available. This might be due to a connection issue or due to the \(radarStation.name) radar station undergoing maintenance. Please try a different station.", systemImage:"exclamationmark.icloud.fill")
                                        .padding()
                                }
                        }
                        
                        VStack{
                            Label("Radar type", image: "radar24x24")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker("Radar type", selection: $appManager.radarType) {
                                ForEach(RadarType.allCases, id: \.self) { type in
                                    Text(String(describing: type))
                                        .tag(type)
                                }
                            }
                           
                            .pickerStyle(.menu)
                            .tint(.white)
                            .task(id: appManager.radarType) {
                                await appManager.refreshRadarImageURL()
                            }
                            
                            Label { Text("Precipitation")} icon:{
                                Image(systemName: "cloud.rain.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            Picker("Precipitation", selection: $appManager.radarPrecipitation) {
                                ForEach(RadarPrecipitation.allCases, id: \.self) { type in
                                    Text("\(type)")
                                        .tag(type)
                                }
                            }
                            .disabled(appManager.radarType == .ACCUM)
                            .pickerStyle(.menu)
                            .tint(.white)
                            .task(id: appManager.radarPrecipitation) {
                                await appManager.refreshRadarImageURL()
                            }
                        }
                        .padding()
                        
                    }
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
    RadarView()
        .foregroundStyle(.white)
        .environmentObject(appManager)
    
}
