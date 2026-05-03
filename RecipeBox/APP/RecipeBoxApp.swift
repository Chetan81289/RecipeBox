//
//  RecipeBoxApp.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 02/05/26.
//

import SwiftUI

@main
struct RecipeBoxApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
