//
//  LocationView.swift
//  AltWeatherCan
//
//  Created by Hanno Rein on 2024-10-27.
//
import SwiftUI

struct LocationView : View {
    @State var searchText : String = ""
    @EnvironmentObject var appManager : AppManager
    @Binding var locationScreenShown : Bool
    
    var searchResults: [Site] {
        if let sites = appManager.sites {
            if searchText.isEmpty {
                return sites
            } else {
                return sites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return []
    }
    
    
    var body: some View {
        
        NavigationStack{
            List{
                ForEach(searchResults, id: \.self) { site in
                    Button {
                        if site != appManager.selectedSite {
                            appManager.selectedSite = site
                            appManager.selectedRadarStation = site.closestRadarStation
                            appManager.citypage = nil
                            appManager.status = .loading
                            Task {
                                await appManager.refresh()
                            }
                        }
                        locationScreenShown = false
                    } label: {
                        HStack{
                            Text("\(site.name), \(site.province)")
                                .tint(.black)
                            if let distance = site.distance{                            Spacer()
                                Text(distance.formatted(.measurement(width: .abbreviated, usage: .general)))
                                    .font(.footnote)
                                    .tint(.gray)
                            }
                        }
                        
                    }
                }
                if !(appManager.sites?.isEmpty == false) {
                    VStack(alignment: .leading){
                        Text("Unable to access weather station list.")
                        Text("Make sure you are connected to the internet.")
                            .font(.footnote)
                    }
                }else if searchResults.isEmpty {
                    Text("No sites found")
                }
            }
            .background(colourTop)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        locationScreenShown.toggle()
                    } label: {
                        HStack{
                            Image("back30x30")
                                .renderingMode(.template)
                            Text("Back")
                        }.foregroundStyle(.white)
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .onAppear {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
            UISearchBar.appearance().tintColor = .white // Color of cancel button
            Task {
                if !(appManager.sites?.isEmpty == false){
                    await appManager.refreshSiteList() // In case site list wasn't downloaded successfully (e.g. no internet on startup)
                }
            }
        }
        
    }
}
#Preview {
    let appManager = AppManager()
    LocationView(locationScreenShown: .constant(true))
        .environmentObject(appManager)
    
}

