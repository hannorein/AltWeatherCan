//
//  File.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-07-08.
//

import Foundation

struct RadarStation : Codable, Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    let province: String
    let region: String
    let code: String
}
