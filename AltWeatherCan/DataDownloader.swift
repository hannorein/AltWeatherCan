//
//  DataDownloader.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-03-27.
//

import Foundation
import XMLCoder

actor DataDownloader {
    func getCitypage(site: Site) async throws -> Citypage {
        let stationUrl = "https://dd.weather.gc.ca/citypage_weather/xml/"+site.province+"/"+site.code+"_e.xml"
        print("Getting \(stationUrl)")
        let sourceXML = try String( contentsOf: URL(string: stationUrl)!, encoding: .utf8)
        return try XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
    }
    
    func getAvailableSites() async throws -> [Site] {
        var newSites: [Site] = []
        let sourceCSV = try String(contentsOf: URL(string: "https://dd.weather.gc.ca/citypage_weather/docs/site_list_en.csv")!, encoding: .utf8)
        var rows = sourceCSV.components(separatedBy: "\n")
        
        rows.removeFirst()
        rows.removeFirst()
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 5 {
                let latitude = Double(columns[3].replacingOccurrences(of: "N", with: ""))
                let longitude = Double("-"+columns[4].replacingOccurrences(of: "W", with: "")) // Hard coded for Canada
                let site = Site(code: columns[0], name: columns[1], province: columns[2], latitude: latitude, longitude: longitude, distance: nil)
                newSites.append(site)
            }
        }
        return newSites
    }
}
