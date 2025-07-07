//
//  Seven_Day.swift
//  Seven Day
//
//  Created by Hanno Rein on 2025-03-27.
//

import WidgetKit
import SwiftUI

let appCornerRadius : CGFloat = 5

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), forecastGroup: nil, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let dataDownloader = DataDownloader()
        let citypage = dataDownloader.getDummyCitypage()
        let forecastGroup = citypage.forecastGroup
        return SimpleEntry(date: Date(), forecastGroup: forecastGroup, configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 1 {
            let defaults = UserDefaults.sharedDefaults
            
            var site = Site(code: "s0000630", name: "Default", province: "ON", latitude: 43.74, longitude: 79.37, distance: nil)
            if let contentData = defaults.object(forKey: "defaultSite") as? Data,
               let defaultSite = try? JSONDecoder().decode(Site.self, from: contentData) {
                site = defaultSite
            }
            print(site)
            
            let dataDownloader = DataDownloader()
            var forecastGroup : ForecastGroup? = nil
            do {
                let newCitypage = try await dataDownloader.getCitypage(site: site)
                forecastGroup = newCitypage.forecastGroup
                print("Downloaded forecast.")
            } catch {
                print("Download error \(error)")
            }
            
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, forecastGroup: forecastGroup, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let forecastGroup : ForecastGroup?
    let configuration: ConfigurationAppIntent
}

struct Seven_DayEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Horizontal7DayViewForWidget(forecastGroup: entry.forecastGroup)
        }
    }
}

struct Seven_Day: Widget {
    let kind: String = "Seven_Day"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Seven_DayEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
                .dynamicTypeSize(.medium)
        }
        .configurationDisplayName("Forecast")
        .description("See the 7 day forecast at a glance! The widget shows the forecast for the location currently selected in the AltWeatherCAN app.")
        .supportedFamilies([
            //.systemSmall,
            .systemMedium,
           // .systemLarge,
            ])
    }
}

#Preview(as: .systemMedium) {
    Seven_Day()
} timeline: {
    let dataDownloader = DataDownloader()
    let citypage = dataDownloader.getDummyCitypage()
    let forecastGroup = citypage.forecastGroup
    SimpleEntry(date: .now, forecastGroup: forecastGroup, configuration: ConfigurationAppIntent())
}
