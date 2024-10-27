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

struct Temperatures : Decodable {
    let temperature: Double
    let textSummary : String
}

struct Forecast : Decodable, Identifiable {
    let id = UUID()
    let period: String
    let textSummary: String
    let abbreviatedForecast: AbbreviatedForecast
    let temperatures: Temperatures
}

struct ForecastGroup : Decodable {
    let forecast: [Forecast]
    let dateTime: [DateTime]
}

struct HourlyForecast : Decodable, Identifiable {
    let id = UUID()
    let dateTimeUTC : String
    var dateTimeLocal: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let date = dateFormatter.date(from:dateTimeUTC)!
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "h a"
        return dateFormatter2.string(from: date).lowercased()
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


struct DateTime : Decodable {
    let name : String
    let UTCOffset : Int
    let timeStamp : String
    let textSummary : String
    var dateTimeLocal: String {
        if (UTCOffset != 0) {
            return "Error. Not UTC."
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let date = dateFormatter.date(from:timeStamp)!
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "H:mm"
        return dateFormatter2.string(from: date)
    }
}

struct RiseSet : Decodable {
    let dateTime : [DateTime]
}

struct Event : Decodable, Identifiable {
    let id = UUID()
    let type : String
    let url : String
    let description : String
    let priority : String
    let dateTime : [DateTime]
}

struct Warnings : Decodable {
    let event: [Event]
}

struct Citypage : Decodable {
    let warnings: Warnings
    let location: Location
    let currentConditions: CurrentConditions
    let forecastGroup: ForecastGroup
    let hourlyForecastGroup: HourlyForecastGroup
    let riseSet : RiseSet
}
