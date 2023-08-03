//
//  GassiView.swift
//  Gassi
//
//  Created by Jan Löffel on 02.08.23.
//

import SwiftUI

struct GassiView: View {
    var body: some View {
        NavigationStack {
            Text("GassiView")
                .navigationTitle(LocalizedStringKey("GassiViewNavigationTitle"))
        }
    }
}

struct GassiView_Previews: PreviewProvider {
    static var previews: some View {
        GassiView()
    }
}
