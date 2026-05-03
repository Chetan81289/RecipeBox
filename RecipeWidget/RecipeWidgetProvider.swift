//
//  RecipeWidgetProvider.swift
//  RecipeWidgetExtension
//
//  Created by Jyoti Purohit on 03/05/26.
//

import WidgetKit
import SwiftUI
import CoreData

struct RecipeWidgetProvider: TimelineProvider {
    let persistenceController = PersistenceController.shared

    func placeholder(in context: Context) -> RecipeWidgetEntry {
        RecipeWidgetEntry(date: Date(), recipeName: "Your next favorite dish", imageData: nil, category: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (RecipeWidgetEntry) -> Void) {
        let entry = RecipeWidgetEntry(date: Date(), recipeName: "Snapshot", imageData: nil, category: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecipeWidgetEntry>) -> Void) {
        let viewContext = PersistenceController.shared.viewContext
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.createdAt, ascending: false)]
        fetchRequest.fetchLimit = 1

        let recipe = try? viewContext.fetch(fetchRequest).first

        // Local function to create an entry (with optional image data)
        func createEntry(imageData: Data?) -> RecipeWidgetEntry {
            let cat = recipe?.categoriesList.first?.name
            return RecipeWidgetEntry(
                date: Date(),
                recipeName: recipe?.wrappedName ?? "No recipes yet",
                imageData: imageData, category: cat
            )
        }

        // If no recipe, just return the empty state immediately
        guard let recipe = recipe else {
            let entry = createEntry(imageData: nil)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
            completion(timeline)
            return
        }

        // If we have a recipe, try to load its image data (if URL exists)
        guard let imageURL = recipe.wrappedImageURL else {
            let entry = createEntry(imageData: nil)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
            completion(timeline)
            return
        }

        // Download the image data in a background task
        URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            let entry = createEntry(imageData: data)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
            completion(timeline)
        }.resume()
    }
}

struct RecipeWidgetEntry: TimelineEntry {
    let date: Date
    let recipeName: String
    let imageData: Data?
    let category: String?
}
