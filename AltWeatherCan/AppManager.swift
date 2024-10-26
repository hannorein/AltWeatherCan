//
//  AppManager.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-26.
//

import Foundation
import XMLCoder

class AppManager : ObservableObject {
    
    @Published var citypage : Citypage? = nil
    
    init() {
        DispatchQueue.global().async {
            do {
                // Hardcoded Toronto URL
                let sourceXML = try String(contentsOf: URL(string: "https://dd.weather.gc.ca/citypage_weather/xml/ON/s0000458_e.xml")!)
                
                //                let path = Bundle.main.path(forResource: "s0000458_e", ofType: "xml") // file path for file "data.txt"
                //                let sourceXML = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
                
                DispatchQueue.main.async{
                    do {
                        self.citypage = try XMLDecoder().decode(Citypage.self, from: Data(sourceXML.utf8))
                        print(self.citypage!)
                    } catch {
                        print("decoding error: \(error)")
                    }
                }
            }catch {
                print("download error: \(error)")
            }
        }
    }
}
