//
//  SettingsView.swift
//  Gassi
//
//  Created by Jan Löffel on 21.08.22.
//

import SwiftUI
import SpoonFW

struct SettingsView: View {
    @EnvironmentObject var settings: CDGassiSettings

    @FetchRequest(fetchRequest: CDGassiCategory.fetchSortedRequest(), animation: .default) private var categories: FetchedResults<CDGassiCategory>
    @FetchRequest(fetchRequest: CDGassiDog.fetchSortedRequest(), animation: .default) private var dogs: FetchedResults<CDGassiDog>

    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                
                Section {
                    NavigationLink {
                        DogsListView()
                    } label: {
                        Label(LocalizedStringKey("SettingsDogs"), systemImage: "pawprint")
                    }

                    NavigationLink {
                        SettingsDogSelectionView()
                    } label: {
                        Label {
                            Text(LocalizedStringKey("SettingsCurrentDog"))
                            Spacer()
                            Text(settings.currentDog?.name ?? ( dogs.count == 0 ? NSLocalizedString("YourDog", comment: "") : NSLocalizedString("AllDogs", comment: "")))
                                .foregroundColor(.accentColor)
                        } icon: {
                            Image(systemName: "rectangle.portrait.topleft.inset.filled")
                        }
                    }

                } header: {
                    Label(LocalizedStringKey("SettingsDogSectionHeader"), systemImage: "pawprint.fill")
                } footer: {
                    Label(LocalizedStringKey("SettingsDogSectionFooter"), systemImage: "info.circle")
                }
                
                Section {
                    NavigationLink {
                        CategoriesListView()
                    } label: {
                        Label(LocalizedStringKey("SettingsCategories"), systemImage: "folder")
                    }
                    
                    Label {
                        Picker(LocalizedStringKey("SettingsFirstFavorite"), selection: $settings.favoriteCategory1) {
                            ForEach(categories, id: \.id) { category in
                                Text("\(category.sign) \(category.name)")
                                    .foregroundColor(.accentColor)
                                    .tag(category as CDGassiCategory?)
                            }
                        }
                    } icon: {
                        Image(systemName: "star")
                    }

                    Label {
                        Picker(LocalizedStringKey("SettingsSecondFavorite"), selection: $settings.favoriteCategory2) {
                            ForEach(categories, id: \.id) { category in
                                Text("\(category.sign) \(category.name)")
                                    .foregroundColor(.accentColor)
                                    .tag(category as CDGassiCategory?)
                            }
                        }
                    } icon: {
                        Image(systemName: "star")
                    }
                } header: {
                    Label(LocalizedStringKey("SettingsCategoriesSectionHeader"), systemImage: "folder.fill")
                } footer: {
                    Label(LocalizedStringKey("SettingsCategoriesSectionFooter"), systemImage: "info.circle")
                }
             
                Section {
                    Stepper(value: $settings.gracePeriod, in: 0...3600, step: 60) {
                        Label {
                            Text(String.localizedStringWithFormat(NSLocalizedString("SettingsGracePeriod", comment: ""), TimeInterval.timeSpanString(settings.gracePeriod, academic: true, showSeconds: false, showNull: true)))
                        } icon: {
                            Image(systemName: "clock.arrow.2.circlepath")
                        }
                    }
 
                    Stepper(value: $settings.groomingDays, in: 1...365) {
                        Label {
                            Text(String.localizedStringWithFormat(NSLocalizedString("SettingsGrooming", comment: ""), settings.groomingDays))
                        } icon: {
                            Image(systemName: "calendar.badge.plus")
                        }
                    }
 
                } header: {
                    Label(LocalizedStringKey("SettingsWalksSectionHeader"), systemImage: "list.bullet.rectangle.fill")
                } footer: {
                    Label(LocalizedStringKey("SettingsWalksSectionFooter"), systemImage: "info.circle")
                }
                
            }
            .toolbar(content: {
                ToolbarItem {
                    Button(role: .destructive) {
                        isPresentingConfirm = true
                    } label: {
                        Label(LocalizedStringKey("ResetAllSettings"), systemImage: "clear")
                    }
                    .confirmationDialog(LocalizedStringKey("ConfirmationDialogTitle"), isPresented: $isPresentingConfirm) {
                        Button(LocalizedStringKey("ResetAllSettings"), role: .destructive) {
//                            CoreDataController.shared.settings = CDGassiSettings()
                        }
                    }
                }
            })
            .navigationTitle(LocalizedStringKey("SettingsViewTitle"))
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CoreDataController.preview.settings)
    }
}
