//
//  DogMoodView.swift
//  Gassi
//
//  Created by Jan Löffel on 15.08.22.
//

import SwiftUI

struct DogMoodView: View {
    @EnvironmentObject var settings: CDGassiSettings
    
    var body: some View {
        VStack {
            if let currentDog = settings.currentDog {
                Text(currentDog.name) + Text(LocalizedStringKey("DogMoodViewIs"))
            } else {
                Text(LocalizedStringKey("DogMoodViewAllYourDogsAre"))
            }
            
            Text("happy.")
        }.padding(25)
            .background(Color("NormalMood"))
            .cornerRadius(15)
            .shadow(color: .secondary, radius: 10, x: 0, y: 0)
            .overlay {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(lineWidth: 2.5)
                    .padding(5)
            }
    }
}

struct DogMoodView_Previews: PreviewProvider {
    static var previews: some View {
        DogMoodView()
            .environmentObject(CoreDataController.preview.settings)
    }
}
