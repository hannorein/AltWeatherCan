//
//  Site.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2024-11-09.
//
import Foundation
import AppIntents

struct Site : Identifiable, Hashable, Codable, AppEntity {
    var id : String {
         code
    }
    let code : String
    let name : String
    let province : String
    let latitude : Double?
    let longitude : Double?
    var distance : Measurement<UnitLength>?
    var closestRadarStation : RadarStation?
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Site"
    
    // 2. Tell the system how to display a single site in a list
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name), \(province)")
    }
    
    // 3. Provide a way for the system to find the site by ID
    static var defaultQuery = SiteQuery()
}


struct SiteQuery: EntityStringQuery {
    // Find a specific site when the widget reloads
    func entities(for identifiers: [String]) async throws -> [Site] {
        let allSites = try await SiteCache.shared.getSites();
        return allSites.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [Site] {
        return try await SiteCache.shared.getSites();
    }
    
    func entities(matching string: String) async throws -> [Site] {
        let allSites = try await SiteCache.shared.getSites();
        return allSites.filter { site in
            site.name.lowercased().hasPrefix(string.lowercased())
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}

// Should be part of AppManager.
class SiteCache {
    static let shared = SiteCache()
    var sites : [Site] = []
    
    func getSites() async throws -> [Site] {
        if sites.isEmpty {
            let dataDownloader = DataDownloader()
            var allSites = try await dataDownloader.getAvailableSites()
            allSites.sort { $0.name < $1.name }
            sites = allSites
            return allSites
        }else{
            return sites
        }
    }
}
