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
        let dataDownLoader = DataDownloader()
        let sites = try await dataDownLoader.getAvailableSites()
        try #require(sites.count > 0, "No sites found.")
        #expect(sites.count(where: { s in
            s.name == "Toronto"
        }) == 1, "Toronto not found.")
        
        // Getting and parsing all station data. This may take a while.
        for (index, site) in sites.enumerated() {
            print("Getting \(index+1)/\(sites.count)")
            let citypage = try await dataDownLoader.getCitypage(site: site)
            if citypage.currentConditions == nil {
                print("No current conditions found.")
            }
        }
    }

}
