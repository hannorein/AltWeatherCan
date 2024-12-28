//
//  AppManager.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import Foundation
import XMLCoder
import CoreLocation


actor DataDownloader {
    func getCitypage(site: Site) async throws -> Citypage {
        let stationUrl = "https://dd.weather.gc.ca/citypage_weather/xml/"+site.province+"/"+site.code+"_e.xml"
        print("Getting \(stationUrl)")
        let sourceXML = try String(contentsOf: URL(string: stationUrl)!)
        return try XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
    }
}

@MainActor
class AppManager : ObservableObject {
    
    @Published var citypage : Citypage? = nil
    @Published var sites : [Site]? = nil
//    @Published var selectedSite = Site(code: "s0000458", name: "Toronto", province: "ON", latitude: 43.74, longitude: 79.37)
//    @Published var selectedSite = Site(code: "s0000630", name: "Port Perry", province: "ON", latitude: 43.74, longitude: 79.37)
    @Published var selectedSite = Site(code: "s0000627", name: "Inukjuak", province: "QC", latitude: 43.74, longitude: 79.37)
    @Published var previousSites : [Site] = []
    private let dataDownloader: DataDownloader

//    var locationManager : CLLocationManager?

    init() {
        let defaults = UserDefaults.standard
        if let contentData = defaults.object(forKey: "defaultSite") as? Data,
            let defaultSite = try? JSONDecoder().decode(Site.self, from: contentData) {
            selectedSite = defaultSite
        }
        if let contentData = defaults.object(forKey: "previousSites") as? Data,
            let _previousSites = try? JSONDecoder().decode([Site].self, from: contentData) {
            previousSites = _previousSites
        }
        self.dataDownloader = DataDownloader()
       
        DispatchQueue.global().async {
            Task {
                await self.refreshSiteList()
                await self.refresh()
            }
        }
    }
    
    func refresh() async {
        do {
            let newCitypage = try await dataDownloader.getCitypage(site: selectedSite)
            
            self.citypage = newCitypage
            // On success only, store site in UserDefaults
            let defaults = UserDefaults.standard
            if let contentData = try? JSONEncoder().encode(self.selectedSite) {
                defaults.set(contentData, forKey: "defaultSite")
            }
            // Store list of previous sites
            self.previousSites.removeAll { s in
                s.code == self.selectedSite.code
            }
            
            self.previousSites.insert(self.selectedSite, at: 0)
            if self.previousSites.count > 10 {
                self.previousSites.removeLast()
            }
            // Re-sort (puts recent ones at top)
            self.sortSiteList()
            
            if let contentData = try? JSONEncoder().encode(self.previousSites) {
                defaults.set(contentData, forKey: "previousSites")
            }else{
                print("encoding error previousSites")
            }
        }catch {
            print("download error: \(error)")
        }
    }
    
    func sortSiteList() {
        if let sites = self.sites {
            self.sites = sites.sorted(by: { a, b in
                return a.name < b.name
            })
            // Move previous selection to top of list.
            for site in previousSites.reversed() {
                if let index = self.sites?.firstIndex(where: { s in
                    s.code == site.code
                }){
                    if let s = self.sites?.remove(at: index){
                        self.sites?.insert(s, at: 0)
                    }
                }
            }
        }
    }
    
    func refreshSiteList() async {
        Task {
            let newSites = Site.getAvailableSites()
            DispatchQueue.main.async{
                self.sites = newSites
                self.sortSiteList()
            }
        }
        
    }
}
