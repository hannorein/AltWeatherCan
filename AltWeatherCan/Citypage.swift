//
//  Citypage.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import Foundation

struct Wind : Decodable {
    let speed: Double
    let gust: Double?
    let direction: String
    
    enum CodingKeys: String, CodingKey {
        case speed
        case gust
        case direction
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        speed = try values.decode(Double.self, forKey: .speed)
        direction = try values.decode(String.self, forKey: .direction)
        do {
            gust = try values.decode(Double.self, forKey: .gust)
        }catch {
            gust = nil
        }
    }
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
}
