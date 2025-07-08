//
//  File.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-07-08.
//

import Foundation

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
}

enum RadarPrecipitation: CaseIterable, Identifiable{
    case Rain
    case Show

    var id: Self { self }
}


struct RadarStation : Codable, Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    let province: String
    let region: String
    let code: String
}
