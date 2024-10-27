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
                        appManager.selectedSite = site
                        Task {
                            await appManager.refresh()
                        }
                        locationScreenShown = false
                    } label: {
                        Text("\(site.name), \(site.province)")
                            .tint(.black)
                    }
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
        }
        
    }
}
#Preview {
    let appManager = AppManager()
    LocationView(locationScreenShown: .constant(true))
        .environmentObject(appManager)
    
}

