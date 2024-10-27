//
//  Citypage.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import Foundation
import XMLCoder

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
    let temperature: Double?
    let dewpoint: Double?
    let pressure: Double?
    let relativeHumidity: Double?
    let visibility: Double?
    let wind: Wind?
    let condition: String?
    let station : String?
    let iconCode : Int?
    let dateTime : [DateTime]
    var iconName : String {
        if let iconCode {
            return String(format: "%02d_main62x63", iconCode)
        }else{
            return "29_main62x63"
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case temperature
        case dewpoint
        case pressure
        case relativeHumidity
        case visibility
        case wind
        case station
        case condition
        case dateTime
        case iconCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        temperature = try values.decode(Double?.self, forKey: .temperature)
        dewpoint = try values.decode(Double?.self, forKey: .dewpoint)
        pressure = try values.decode(Double?.self, forKey: .pressure)
        relativeHumidity = try values.decode(Double?.self, forKey: .relativeHumidity)
        visibility = try values.decode(Double?.self, forKey: .visibility)
        wind = try values.decode(Wind?.self, forKey: .wind)
        condition = try values.decode(String?.self, forKey: .condition)
        station = try values.decode(String?.self, forKey: .station)
        dateTime = try values.decode([DateTime].self, forKey: .dateTime)
        do {
            iconCode = try values.decode(Int.self, forKey: .iconCode)
        }catch {
            iconCode = 29 // N/A icon.
        }
    }
}

struct Province: Decodable, DynamicNodeEncoding {
    let code: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case code
        case name = ""
    }

    static func nodeEncoding(for key: any CodingKey) -> XMLCoder.XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.code:
            return .attribute
        default:
            return .element
        }
    }
}

struct Location : Decodable {
    let name: String
    let province: Province
}

struct AbbreviatedForecast : Decodable {
    let iconCode : Int
    var pop : Double?
    var iconName : String {
        return String(format: "%02d_main62x63", iconCode)
    }
    let textSummary: String
    
    enum CodingKeys: String, CodingKey {
        case iconCode
        case pop
        case textSummary
    }
    init() {
        iconCode = 29
        pop = nil
        textSummary = ""
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        iconCode = try values.decode(Int.self, forKey: .iconCode)
        textSummary = try values.decode(String.self, forKey: .textSummary)
        do {
            pop = try values.decode(Double?.self, forKey: .pop)
        }
    }
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
    let currentConditions: CurrentConditions?
    let forecastGroup: ForecastGroup
    let hourlyForecastGroup: HourlyForecastGroup
    let riseSet : RiseSet
}
