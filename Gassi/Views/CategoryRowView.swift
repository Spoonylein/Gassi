//
//  CategoryRowView.swift
//  Gassi
//
//  Created by Jan Löffel on 13.08.22.
//

import SwiftUI

struct CategoryRowView: View {
    @EnvironmentObject var settings: CDGassiSettings

    @ObservedObject var gassiCategory: CDGassiCategory

    var body: some View {
        let isFavorite = settings.favoriteCategory1 == gassiCategory || settings.favoriteCategory2 == gassiCategory
        
        HStack {
            Text(gassiCategory.sign)
            Text(gassiCategory.name)
                .fontWeight(gassiCategory.isDefault ? .bold : .regular)
            HStack {
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.secondary)
            }
            .isHidden(!isFavorite, remove: !isFavorite)
        }
    }
}

struct CategoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRowView(gassiCategory: CoreDataController.preview.settings.favoriteCategory2!)
            .environmentObject(CoreDataController.preview.settings)
    }
}
