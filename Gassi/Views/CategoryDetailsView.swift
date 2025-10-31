//
//  CategoryDetailsView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI
import SpoonFW

struct CategoryDetailsView: View {
    @EnvironmentObject var settings: CDGassiSettings

    @FetchRequest(fetchRequest: CDGassiEvent.sortedFetchRequest(ascending: false), animation: .default) private var events: FetchedResults<CDGassiEvent>

    @ObservedObject var gassiCategory: CDGassiCategory
    
    @State private var name: String = NSLocalizedString("NoName", comment: "")
    @State private var sign: String = ""
    @State private var isFavorite = false
    @State private var isDefault = false

    var body: some View {
        Form {
            List {
                
                Section {
                    Label {
                        Text(LocalizedStringKey("CategoryName"))
                        Spacer()
                        TextField(LocalizedStringKey("CategoryName"), text: $name)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.accentColor)
                            .textFieldStyle(.roundedBorder)
                    } icon: {
                        Image(systemName: "square.and.pencil")
                    }
                    
                    Label {
                        Text(LocalizedStringKey("CategorySign"))
                        Spacer()
                        TextField(LocalizedStringKey("CategorySign"), text: $sign)
                            .multilineTextAlignment(.center)
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: 64)
                            .textFieldStyle(.roundedBorder)
                    } icon: {
                        Image(systemName: "face.smiling")
                    }
                } header: {
                    Label(LocalizedStringKey("CategoryDetailsNameSectionHeader"), systemImage: "doc.plaintext.fill")
                } footer: {
                    Label(LocalizedStringKey("CategoryDetailsNameSectionFooter"), systemImage: "info.circle")
                }
                
                Section {
                    Toggle(isOn: $isFavorite) {
                        Label {
                            Text(LocalizedStringKey("CategoryFavorite"))
                        } icon: {
                            Image(systemName: "star")
                        }
                    }

                    Toggle(isOn: $isDefault) {
                        Label {
                            Text(LocalizedStringKey("CategoryDefault"))
                        } icon: {
                            Image(systemName: "bold")
                        }
                    }
                } header: {
                    Label(LocalizedStringKey("CategoryDetailsFavoriteSectionHeader"), systemImage: "star.fill")
                } footer: {
                    Label(LocalizedStringKey("CategoryDetailsFavoriteSectionFooter"), systemImage: "info.circle")
                }
                
                Section {
                    List {
                        ForEach(events.filter({ event in return event.category == gassiCategory }), id: \.id) { item in
                            EventRowView(gassiEvent: item)
                        }
                    }
                } header: {
                    Label(LocalizedStringKey("CategoryDetailsEventsSectionHeader"), systemImage: "pawprint.fill")
                } footer: {
                    Label(LocalizedStringKey("CategoryDetailsEventsSectionFooter"), systemImage: "info.circle")
                }
                
            }
            
        }
        .onAppear {
            name = gassiCategory.name
            sign = gassiCategory.sign
            isFavorite = settings.favoriteCategory1 == gassiCategory || settings.favoriteCategory2 == gassiCategory
            isDefault = gassiCategory.isDefault
        }
        .onDisappear {
            gassiCategory.name = name.trim()
            gassiCategory.sign = sign.left()
            if isFavorite {
                settings.addFavorite(gassiCategory)
            } else {
                settings.removeFavorite(gassiCategory)
            }
            gassiCategory.isDefault = isDefault
        }
        .navigationTitle(LocalizedStringKey("CategoryDetailsViewTitle"))
    }
}

struct CategoryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryDetailsView(gassiCategory: CoreDataController.preview.settings.favoriteCategory1!)
        }
        .environmentObject(CoreDataController.preview.settings)
    }
}
