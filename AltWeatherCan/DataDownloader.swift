//
//  DataDownloader.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-03-27.
//

import Foundation
import XMLCoder

actor DataDownloader {
    private func getCityPageURL(site: Site) throws -> URL {
        // Logic from:
        // https://github.com/michaeldavie/env_canada/blob/ad00149cd288f6cf30aa7e206b29dde3940fc578/env_canada/ec_weather.py#L302
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "HH"
        
        let calendar = Calendar.current
        
        for hours_back in 0...3 {  // Check current hour and 3 hours back
            let check_date = calendar.date(byAdding: .hour, value: -hours_back, to: Date())!
            let hour_str = dateFormatter.string(from: check_date)
            
            // Construct directory URL
            let directory_url = "https://dd.weather.gc.ca/citypage_weather/"+site.province+"/"+hour_str+"/"
            do {
                let html_content = try String( contentsOf: URL(string: directory_url)!, encoding: .utf8)
                
                // Parse HTML directory listing to find matching files
                let file_pattern = try Regex("20[^\"]*MSC_CitypageWeather_"+site.code+"_en\\.xml")
                
                var matchedStrings: [String] = []
                for match in html_content.matches(of: file_pattern){
                    matchedStrings.append(String(match.0))
                }
                if matchedStrings.count > 0 {
                    matchedStrings.sort()
                    return URL(string: directory_url + matchedStrings.last!)!
                }
            }catch{
                continue;
            }
        }
        throw NSError(domain: "getCityPageURL failed to find URL", code: 1, userInfo: nil)
    }
    
    func getCitypage(site: Site) async throws -> Citypage {
        let stationUrl = try getCityPageURL(site: site)
        print("Getting \(stationUrl)")
        let sourceXML = try String( contentsOf: stationUrl, encoding: .utf8)
        return try XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
    }
    
    nonisolated func getDummyCitypage() -> Citypage {
        let stationUrl = Bundle.main.url(forResource: "s0000630_e", withExtension: "xml")!
        let sourceXML = try! String( contentsOf: stationUrl, encoding: .utf8)
        return try! XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
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
