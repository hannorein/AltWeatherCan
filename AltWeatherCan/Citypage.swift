//
//  Citypage.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import XMLCoder
import Foundation
import SwiftUI

struct Wind : Decodable {
    let speed: Double
    let gust: Double
    let direction: String
}

struct CurrentConditions : Decodable {
    let temperature: Double
    let dewpoint: Double
    let pressure: Double
    let wind: Wind
    let condition: String
    let iconCode : Int
    var iconName : String {
        return String(format: "%02d_main62x63", iconCode)
    }
}

struct Location : Decodable {
    let name: String
    let province: String
}

struct AbbreviatedForecast : Decodable {
    let iconCode : Int
    var iconName : String {
        return String(format: "%02d_main62x63", iconCode)
    }
    let textSummary: String
}

struct Forecast : Decodable {
    let period: String
    let textSummary: String
    let abbreviatedForecast: AbbreviatedForecast
}

struct ForecastGroup : Decodable {
    let forecast: Forecast
}

struct HourlyForecast : Decodable {
    let dateTimeUTC : String
    var dateTimeLocal: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let date = dateFormatter.date(from:dateTimeUTC)!
        return date.formatted(date: .omitted, time: .shortened)
    }
    let temperature: Double
    let iconCode : Int
    var iconName : String {
        return String(format: "%02d_main62x63", iconCode)
    }
}

struct HourlyForecastGroup : Decodable {
    let hourlyForecast: [HourlyForecast]
}
 
struct Citypage : Decodable {
    var location: Location? = nil
    var currentConditions: CurrentConditions? = nil
    var forecastGroup: ForecastGroup? = nil
    var hourlyForecastGroup: HourlyForecastGroup? = nil
    
    static func load() -> Citypage? {
        let path = Bundle.main.path(forResource: "s0000458_e", ofType: "xml") // file path for file "data.txt"
        let sourceXML = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        do {
            let citypage = try XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
            print(citypage)
            return citypage
        }catch {
            print("error: \(error)")
        }
        return nil
    }
    
}

#Preview {
    MainView()
    
}
