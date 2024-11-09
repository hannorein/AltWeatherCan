//
//  AltWeatherCANTests.swift
//  AltWeatherCANTests
//
//  Created by Hanno Rein on 2024-11-09.
//

import Testing
import Foundation
import XMLCoder

struct AltWeatherCANTests {

    @Test func getAllSites() async throws {
        let sites = Site.getAvailableSites()
        try #require(sites.count > 0, "No sites found.")
        #expect(sites.count(where: { s in
            s.name == "Toronto"
        }) == 1, "Toronto not found.")
        
        // Getting and parsing all station data. This may take a while.
        for (index, site) in sites.enumerated() {
            let stationUrl = "https://dd.weather.gc.ca/citypage_weather/xml/"+site.province+"/"+site.code+"_e.xml"
            print("Getting \(index+1)/\(sites.count): \(stationUrl)")
            let sourceXML = try String(contentsOf: URL(string: stationUrl)!, encoding: .utf8)
            
            let citypage = try XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
            if citypage.currentConditions == nil {
                print("No current conditions found.")
            }
        }
    }

}
