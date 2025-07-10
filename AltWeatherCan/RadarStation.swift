//
//  File.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-07-08.
//

import Foundation
import Combine
import SwiftUI

enum RadarType: CaseIterable, Identifiable, CustomStringConvertible{
    case CAPPI
    case DPQPE
    case ACCUM

    var id: Self { self }

    var description: String {
        switch self {
        case .CAPPI:
            return "Constant Altitude Plan Position Indicator"
        case .DPQPE:
            return "Dual Polarization Quantitative Precipitation Estimation"
        case .ACCUM:
            return "24h Accumulation"
        }
    }
    var urlComponent: String {
        switch self {
        case .CAPPI:
            return "CAPPI"
        case .DPQPE:
            return "DPQPE"
        case .ACCUM:
            return "24_HR_ACCUM"
        }
    }
}

enum RadarPrecipitation: CaseIterable, Identifiable{
    case Rain
    case Snow

    var id: Self { self }
    
    var urlComponent: String {
        switch self {
        case .Rain:
            return "RAIN"
        case .Snow:
            return "SNOW"
        }
    }
}

class RadarImage : ObservableObject, Hashable, Identifiable {
    @Published var url: URL
    @Published var date: Date
    @Published var image: UIImage?
    private var dataTask: URLSessionDataTask?

    func requestImage() {
        if image != nil {
            return
        }
        if dataTask != nil {
            return
        }
        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async { // Ensure UI updates on the main thread
                if let error = error {
                    // Check for task cancellation error
                    if (error as NSError).code == NSURLErrorCancelled {
                        print("Image download task cancelled.")
                        return // Do not set an error if cancelled
                    }
                    self?.image = nil // Clear image on error
                    return
                }
                
                guard let data = data, let loadedImage = UIImage(data: data) else {
                    print("Could not decode image or no data")
                    self?.image = nil
                    return
                }
                self?.image = loadedImage
            }
        }
        dataTask?.resume() // Start the download
    }
    
    static func == (lhs: RadarImage, rhs: RadarImage) -> Bool {
        lhs.url == rhs.url
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    init(url: URL, date: Date) {
        self.url = url
        self.date = date
        self.image = nil
    }
    deinit {
         dataTask?.cancel()
     }
}

struct RadarStation : Codable, Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    let province: String
    let region: String
    let code: String
}
