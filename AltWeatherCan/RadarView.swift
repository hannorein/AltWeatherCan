//
//  HourlyView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//
import SwiftUI
import Combine

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}


struct RadarView : View {
    @EnvironmentObject var appManager : AppManager
    @State private var index : Int = 0
    @State private var radarSpeed : Double = 0.4
    @State private var timerCancellable: AnyCancellable?
    @State private var timerIsRunning: Bool = false
    
    private var timerPublisher: AnyPublisher<Date, Never> {
        Timer.publish(every: radarSpeed, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }
    
    private func connectTimer() {
        disconnectTimer()
        timerCancellable = timerPublisher
            .sink { _ in
                var nindex = self.index - 1
                if nindex < 0 {
                    nindex = self.appManager.latestRadarImages.count - 1
                }
                self.index = nindex
            }
    }
    
    private func disconnectTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    var body: some View {
        HStack{
            Spacer()
            VStack{
                if let radarStation = appManager.selectedSite.closestRadarStation {
                    ScrollView(.vertical) {
                        if appManager.latestRadarImages.count != 0 {
                            let radarImage = appManager.latestRadarImages[min(index, appManager.latestRadarImages.count-1)]
                            RadarImageView(radarImage: radarImage)
                                .onAppear(perform: {
                                    appManager.latestRadarImages[index].requestImage()
                                })
                                .onChange(of: index) {
                                    appManager.latestRadarImages[index].requestImage()
                                }
                                .onChange(of: appManager.latestRadarImages) {
                                    appManager.latestRadarImages[index].requestImage()
                                }
                        }else{
                            Rectangle()
                                .foregroundStyle(.clear)
                                .aspectRatio(580.0/480.0, contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .overlay {
                                    Label("No radar images available. This might be due to a connection issue or due to the \(radarStation.name) radar station undergoing maintenance. Please try a different station.", systemImage:"exclamationmark.icloud.fill")
                                        .padding()
                                }
                        }
                        
                        
                        VStack(alignment: .center){
                            HStack{
                                Image(systemName: "clock.fill")
                                    .resizable()
                                    .scaleEffect(1.3)
                                    .scaledToFit()
                                    .foregroundStyle(colourIcons)
                                    .frame(width: 16, height: 16)
                                Text("Time")
                                
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                            if let radarImage = appManager.latestRadarImages[safe: index] {
                                Text("Observed on ") + Text(radarImage.date, format: .dateTime.weekday(.wide).day().month(.wide).hour().minute().timeZone())
                                    .monospacedDigit()
                            }else{
                                Text("No image available.")
                            }

                            FrameSlider(intValue: $index, maxValue: appManager.latestRadarImages.count-1)
                                .disabled(appManager.latestRadarImages.count == 0)
                                .controlSize(.large) // Makes the system style larger
                                .buttonStyle(.bordered)
                                .foregroundStyle(colourIcons)
                                .padding(.horizontal)
                            
                            HStack{
                                if (timerIsRunning){
                                    Button {
                                        timerIsRunning = false
                                        disconnectTimer()
                                    } label: {
                                        Label("Pause", systemImage: "pause.fill")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .frame(maxWidth: .infinity)
                                }else{
                                    Button {
                                        appManager.latestRadarImages.forEach { image in
                                            image.requestImage()
                                        }
                                        timerIsRunning  = true
                                        connectTimer()
                                    } label: {
                                        Label("Play", systemImage: "play.fill")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                Spacer()
                                Button {
                                    radarSpeed /= 0.8
                                    if radarSpeed < 0.05 {
                                        radarSpeed = 0.05
                                    }
                                    disconnectTimer()
                                    connectTimer()
                                } label: {
                                    Label("Slower", systemImage: "tortoise.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .cornerRadius(0)
                                .frame(maxWidth: .infinity)
                                .disabled(radarSpeed==1.0)
                                Spacer()
                                Button {
                                    radarSpeed *= 0.8
                                    if radarSpeed > 1.0 {
                                        radarSpeed = 1.0
                                    }
                                    disconnectTimer()
                                    connectTimer()
                                } label: {
                                    Label("Faster", systemImage: "hare.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                                .disabled(radarSpeed==0.05)
                                
                            }
//                            .controlSize(.large)
                            .buttonStyle(.bordered)
                            .foregroundStyle(colourIcons)
                            .padding(.horizontal)
                            
                            Divider()
                                .frame(height:4)
                            
                            
                            
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
                                timerIsRunning = false
                                disconnectTimer()
                                await appManager.refreshRadarImageURL()
                            }
                            
                            Divider()
                                .frame(height:4)
                            
                            
                            HStack{
                                Image(systemName: "cloud.rain.fill")
                                    .resizable()
                                    .scaleEffect(1.3)
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
                                timerIsRunning = false
                                disconnectTimer()
                                await appManager.refreshRadarImageURL()
                            }
                            
                            Divider()
                                .frame(height:4)
                            
                            HStack{
                                Image(systemName: "mappin.and.ellipse")
                                    .resizable()
                                    .scaleEffect(1.3)
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
                                timerIsRunning = false
                                disconnectTimer()
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
            .onDisappear(perform: { disconnectTimer() })
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [colourTop, colourTop, colourBottom]), startPoint: .top, endPoint: .bottom)
        )
    }
}

struct RadarImageView : View {
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero
    @ObservedObject var radarImage: RadarImage
    
    var body: some View {
        if let image = radarImage.image {
            Image(uiImage: image)
                .resizable()
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
        }else{
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
}



// Reverse slider for integer values that also works for empty ranges
struct FrameSlider : View {
    @Binding var intValue: Int
    var maxValue: Int
    
    var body: some View {
        Slider(value: Binding(
            get: { Double(maxValue-intValue) },
            set: { intValue = Int(Double(maxValue)-$0.rounded()) }
        ),
               in: 0.0...Double(max(1,maxValue)),
               step: 1,
               label: { Text("Frame") }
        )
    }
}


#Preview {
    let appManager = AppManager()
    RadarView()
        .foregroundStyle(.white)
        .environmentObject(appManager)
    
}
