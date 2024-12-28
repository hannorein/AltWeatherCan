//
//  Site.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2024-11-09.
//
import Foundation

struct Site : Identifiable, Hashable, Codable {
    var id = UUID()
    let code : String
    let name : String
    let province : String
    let latitude : Double?
    let longitude : Double?
}
