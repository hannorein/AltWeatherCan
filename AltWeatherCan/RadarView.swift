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
                        
                        
                        VStack(alignment: .center){
                            HStack{
                                Image("radar24x24")
                                    .colorMultiply(colourIcons)
                                    .frame(width: 16, height: 16)
                                Text("Radar type")
                                
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                            
                            Picker("Radar type", selection: $appManager.radarType) {
                                ForEach(RadarType.allCases, id: \.self) { type in
                                    Text(String(describing: type))
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .tint(.black)
                            .task(id: appManager.radarType) {
                                await appManager.refreshRadarImageURL()
                            }
                            
                            Divider()
                                .frame(height:4)
                            
                            
                            HStack{
                                Image(systemName: "cloud.rain.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(colourIcons)
                                    .frame(width: 16, height: 16)
                                Text("Precipitation type")
                                
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                            
                            Picker("Precipitation", selection: $appManager.radarPrecipitation) {
                                ForEach(RadarPrecipitation.allCases, id: \.self) { type in
                                    Text("\(type)")
                                        .tag(type)
                                }
                            }
                            .disabled(appManager.radarType == .ACCUM)
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .tint(.black)
                            .task(id: appManager.radarPrecipitation) {
                                await appManager.refreshRadarImageURL()
                            }
                            
                            Divider()
                                .frame(height:4)
                            
                            HStack{
                                Image(systemName: "mappin.and.ellipse")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(colourIcons)
                                    .frame(width: 16, height: 16)
                                Text("Radar station")
                                
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                            
                            Picker("Radar station", selection: $appManager.selectedRadarStation) {
                                ForEach(appManager.availableRadarStations, id: \.self) { radarStation in
                                    Text("\(radarStation.region) (\(radarStation.name))")
                                        .tag(radarStation)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .tint(.black)
                            .task(id: appManager.selectedRadarStation) {
                                await appManager.refreshRadarImageURL()
                            }

                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                        .foregroundStyle(.black)
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: appCornerRadius)
                                .fill(.white)
                        )
                        
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
