//
//  UserDefaultsExtension.swift
//  AltWeatherCAN
//
//  Created by Hanno Rein on 2025-07-07.
//

import Foundation

extension UserDefaults {
    static var sharedDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: "group.de.hanno-rein.AltWeatherCAN") else {
            fatalError("Could not create shared UserDefaults")
        }
        return defaults
    }
}
