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
    
    static func getAvailableSites() -> [Site] {
        var newSites: [Site] = []
        do {
            let sourceCSV = try String(contentsOf: URL(string: "https://dd.weather.gc.ca/citypage_weather/docs/site_list_en.csv")!)
                var rows = sourceCSV.components(separatedBy: "\n")

                rows.removeFirst()
                rows.removeFirst()

                for row in rows {
                    let columns = row.components(separatedBy: ",")
                    if columns.count >= 5 {
                        let latitude = Double(columns[3].replacingOccurrences(of: "N", with: ""))
                        let longitude = Double("-"+columns[4].replacingOccurrences(of: "W", with: "")) // Hard coded for Canada
                        let site = Site(code: columns[0], name: columns[1], province: columns[2], latitude: latitude, longitude: longitude)
                        newSites.append(site)
                    }
            }
        }catch {
            print("download error: \(error)")
        }
        return newSites
    }
}
