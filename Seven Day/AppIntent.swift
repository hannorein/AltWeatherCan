//
//  AppIntent.swift
//  Seven Day
//
//  Created by Hanno Rein on 2025-03-27.
//

import WidgetKit
import AppIntents


struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }    
    @Parameter(title: "Location")
    var site: Site?
}
