//
//  DataDownloader.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-03-27.
//

import Foundation
import XMLCoder
import CoreLocation

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
            let directory_url = "https://dd.weather.gc.ca/today/citypage_weather/"+site.province+"/"+hour_str+"/"
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
    
    func getLatestRadarImages(radarStation: RadarStation, radarType: RadarType, radarPrecipitation: RadarPrecipitation) -> [RadarImage] {
        var radarImages : Set<RadarImage> = []
        
        let url_end = (radarType != .ACCUM) ? "(?i)\(radarPrecipitation.urlComponent)" : "Accum24h"
        guard let file_pattern = try? Regex("20[^\"]*_\(url_end).gif") else{
            print("Regex error")
            return []
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmm'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        
        let directory_url = "https://dd.meteo.gc.ca/today/radar/\(radarType.urlComponent)/GIF/\(radarStation.code)/?C=M;O=D"
        if let html_content = try? String( contentsOf: URL(string: directory_url)!, encoding: .utf8) {
            for match in html_content.matches(of: file_pattern) {
                if let date = dateFormatter.date(from: String(match.0.prefix(14))) {
                    let image_url = "https://dd.meteo.gc.ca/today/radar/\(radarType.urlComponent)/GIF/\(radarStation.code)/\(match.0)"
                    radarImages.insert(RadarImage(url: URL(string: image_url)!, date: date))
                }else{
                    print("Error: Could not convert string \(String(match.0.prefix(14))) to Date.")
                }
            }
        } else {
            print("Download error (today) for \(directory_url)")
            // Don't fail just yet. Check yesterday
        }
        
        // Check yesterday's dataset if not enough images found.
        if (radarImages.count < 30 ){
            print("checking yesterday")
            let directory_url = "https://dd.meteo.gc.ca/yesterday/radar/\(radarType.urlComponent)/GIF/\(radarStation.code)/?C=M;O=D"
            if let html_content = try? String( contentsOf: URL(string: directory_url)!, encoding: .utf8) {
                for match in html_content.matches(of: file_pattern) {
                    if let date = dateFormatter.date(from: String(match.0.prefix(14))) {
                        let image_url = "https://dd.meteo.gc.ca/yesterday/radar/\(radarType.urlComponent)/GIF/\(radarStation.code)/\(match.0)"
                        radarImages.insert(RadarImage(url: URL(string: image_url)!, date: date))
                    }else{
                        print("Error: Could not convert string \(String(match.0.prefix(14))) to Date.")
                    }
                }
            }
        }
        
        let sortedRadarImages = radarImages.sorted { $0.date > $1.date }
        guard let latestImage = sortedRadarImages.first else{
            print("No radar url matches found")
            return []
        }
        let last3hoursRadarImages = sortedRadarImages.filter { latestImage.date.timeIntervalSince($0.date) < 3*60*60 }
        return last3hoursRadarImages.sorted { $0.date > $1.date }
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
        let sourceCSV = try String(contentsOf: URL(string: "https://dd.weather.gc.ca/today/citypage_weather/docs/site_list_en.csv")!, encoding: .utf8)
        var rows = sourceCSV.components(separatedBy: "\n")
        
        rows.removeFirst()
        rows.removeFirst()
        
        let radarStations = getAvailableRadarStations()
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 5 {
                let latitude = Double(columns[3].replacingOccurrences(of: "N", with: ""))
                let longitude = Double("-"+columns[4].replacingOccurrences(of: "W", with: "")) // Hard coded for Canada
                var closestRadarStation : RadarStation? = nil
                var cd = 1000000000.0
                if let latitude, let longitude {
                    for radarStation in radarStations {
                        let sl = CLLocation(latitude: latitude, longitude: longitude)
                        let rl = CLLocation(latitude: radarStation.latitude, longitude: radarStation.longitude)
                        let nd = sl.distance(from: rl)
                        if nd < cd {
                            closestRadarStation = radarStation
                            cd = nd
                        }
                    }
                }
                let site = Site(code: columns[0], name: columns[1], province: columns[2], latitude: latitude, longitude: longitude, distance: nil, closestRadarStation: closestRadarStation)
                newSites.append(site)
            }
        }
        return newSites
    }
    
    nonisolated func getAvailableRadarStations() -> [RadarStation] {
        let url = Bundle.main.url(forResource: "radarstations", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        let radarStations = try! decoder.decode([RadarStation].self, from: data)
        return radarStations
    }
}
