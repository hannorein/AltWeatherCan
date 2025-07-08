//
//  AppManager.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import Foundation
import XMLCoder
import CoreLocation
import WidgetKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var manager : CLLocationManager
    weak var appManager : AppManager? = nil
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
    }
    func startUpdatingLocation() {
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100.0
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            Task{
                if let appManager = self.appManager {
                    await appManager.updateLocation(loc: loc)
                }
            }
        }
    }
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location error (ignored) \(error).")
    }
}

enum AltWeatherCanStatus {
    case loading
    case success
    case error
}

@MainActor
class AppManager : ObservableObject {
    
    @Published var citypage : Citypage? = nil
    @Published var sites : [Site]? = nil
    @Published var selectedSite = Site(code: "s0000627", name: "Inukjuak", province: "QC", latitude: 43.74, longitude: 79.37, distance: nil)
    @Published var status : AltWeatherCanStatus = .loading
    @Published var location : CLLocation? = nil
    @Published var latestRadarImageURL : URL? = nil
    var previousSites : [Site] = []
    private var closestSite : Site? = nil
    private let dataDownloader: DataDownloader
    private let locationManager : LocationManager


    init() {
        let defaults = UserDefaults.sharedDefaults
        if let contentData = defaults.object(forKey: "defaultSite") as? Data,
            let defaultSite = try? JSONDecoder().decode(Site.self, from: contentData) {
            selectedSite = defaultSite
        }else{
            // Check for previously stored settings in standard UserDefaults. Can be removed in future.
            let defaults = UserDefaults.standard
            if let contentData = defaults.object(forKey: "defaultSite") as? Data,
               let defaultSite = try? JSONDecoder().decode(Site.self, from: contentData) {
                selectedSite = defaultSite
            }
        }
        if let contentData = defaults.object(forKey: "previousSites") as? Data,
            let _previousSites = try? JSONDecoder().decode([Site].self, from: contentData) {
            previousSites = _previousSites
        }else{
            // Check for previously stored settings in standard UserDefaults. Can be removed in future.
            let defaults = UserDefaults.standard
            if let contentData = defaults.object(forKey: "previousSites") as? Data,
                let _previousSites = try? JSONDecoder().decode([Site].self, from: contentData) {
                previousSites = _previousSites
            }
        }
        self.dataDownloader = DataDownloader()
        self.locationManager = LocationManager()
        
        self.locationManager.appManager = self
        self.locationManager.startUpdatingLocation()
        
        Task {
            await self.refreshSiteList()
            await self.refresh()
        }
    }
    
    func refresh() async {
        do {
            let newCitypage = try await dataDownloader.getCitypage(site: selectedSite)
            self.citypage = newCitypage
            self.status = citypage==nil ? .error : .success
            
            // On success only, store site in UserDefaults
            let defaults = UserDefaults.sharedDefaults
            if let contentData = try? JSONEncoder().encode(self.selectedSite) {
                defaults.set(contentData, forKey: "defaultSite")
                WidgetCenter.shared.reloadAllTimelines()
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
            if (sites?.isEmpty == false){
                self.sortSiteList()
            }else{
                await self.refreshSiteList() // In case site list wasn't downloaded successfully (e.g. no internet on startup)
            }
            
            if let contentData = try? JSONEncoder().encode(self.previousSites) {
                defaults.set(contentData, forKey: "previousSites")
            }else{
                print("encoding error previousSites")
            }
            if let closestRadarStation = selectedSite.closestRadarStation {
                latestRadarImageURL = await dataDownloader.getLatestRadarImageUrl(radarStation: closestRadarStation)
            }else{
                latestRadarImageURL = nil
            }
        }catch {
            self.status = .error
            latestRadarImageURL = nil
            print("download error: \(error)")
        }
    }
    
    func sortSiteList() {
        if let sites = self.sites {
            // Alphabetic sort
            //            self.sites = sites.sorted(by: { a, b in
            //                return a.name < b.name
            //            })
            // Distance first (places without distance last), then alphabetic
            self.sites = sites.sorted(by: { a, b in
                if let ad = a.distance, let bd = b.distance {
                    return ad < bd
                }else if a.distance != nil { // place without distance last
                    return true
                }else if b.distance != nil { // place without distance last
                    return false
                }
                return a.name < b.name
            })
            self.closestSite = self.sites?.first
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
        do{
            let newSites = try await dataDownloader.getAvailableSites()
            self.sites = newSites
            updateSiteDistances()
        }catch {
            print("Unable to download site list.")
        }
    }
    
    func updateLocation(loc: CLLocation) {
        location = loc
        updateSiteDistances()
        let defaults = UserDefaults.sharedDefaults
        // Check if previously stored in standard UserDefaults. Can be removed in future.
        defaults.set(UserDefaults.standard.bool(forKey: "locationReceivedOnce"), forKey: "locationReceivedOnce")
        // Normal:
        let gotLocationBefore = defaults.bool(forKey: "locationReceivedOnce")
        if !gotLocationBefore {
            if let closestSite = self.closestSite {
                defaults.set(true, forKey: "locationReceivedOnce")
                self.selectedSite = closestSite
                self.citypage = nil
                Task {
                    await self.refresh()
                }
            }
        }
        
    }
    func updateSiteDistances() {
        if var sites, let location {
            for index in 0..<sites.count {
                if let latitude = sites[index].latitude, let longitude = sites[index].longitude {
                    let sl = CLLocation(latitude: latitude, longitude: longitude)
                    sites[index].distance = Measurement(value: sl.distance(from: location), unit: .meters)
                }
            }
            self.sites = sites
        }
        self.sortSiteList()
    }
}
