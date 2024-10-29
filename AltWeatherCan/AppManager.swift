//
//  AppManager.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import Foundation
import XMLCoder

struct Site : Identifiable, Hashable {
    let id = UUID()
    let code : String
    let name : String
    let province : String
    let latitude : Double?
    let longitude : Double?
}

class AppManager : ObservableObject {
    
    @Published var citypage : Citypage? = nil
    @Published var sites : [Site]? = nil
//    @Published var selectedSite = Site(code: "s0000458", name: "Toronto", province: "ON", latitude: 43.74, longitude: 79.37)
//    @Published var selectedSite = Site(code: "s0000630", name: "Port Perry", province: "ON", latitude: 43.74, longitude: 79.37)
    @Published var selectedSite = Site(code: "s0000627", name: "Inukjuak", province: "QC", latitude: 43.74, longitude: 79.37)
    
    init() {
        DispatchQueue.global().async {
            Task {
                await self.refreshSiteList()
                await self.refresh()
            }
        }
    }
    
    func refresh() async {
        do {
            print("Getting https://dd.weather.gc.ca/citypage_weather/xml/"+selectedSite.province+"/"+selectedSite.code+"_e.xml")
            let sourceXML = try String(contentsOf: URL(string: "https://dd.weather.gc.ca/citypage_weather/xml/"+selectedSite.province+"/"+selectedSite.code+"_e.xml")!)
            
            DispatchQueue.main.async{
                do {
                    self.citypage = try XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
//                    print(self.citypage!)
                } catch {
                    print("decoding error: \(error)")
                }
            }
        }catch {
            print("download error: \(error)")
        }
    }
    
    func refreshSiteList() async {
        
        do {
            let sourceCSV = try String(contentsOf: URL(string: "https://dd.weather.gc.ca/citypage_weather/docs/site_list_en.csv")!)
            DispatchQueue.main.async{
                var newSites: [Site] = []

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
                self.sites = newSites.sorted(by: { a, b in
                    a.name < b.name
                })
            }
        }catch {
            print("download error: \(error)")
        }
        
        
    }
}
