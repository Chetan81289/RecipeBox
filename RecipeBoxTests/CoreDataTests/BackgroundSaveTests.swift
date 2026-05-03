//
//  BackgroundSaveTests.swift
//  RecipeBoxTests
//
//  Created by Chetan purohit on 04/05/26.
//

import XCTest
import CoreData
@testable import RecipeBox

final class BackgroundSaveTests: XCTestCase {
    var controller: PersistenceController!

    override func setUp() {
        super.setUp()
        controller = PersistenceController.testInstance
    }

    func testBackgroundContext_SavesAndMerges() async {
        let bgContext = controller.newBackgroundContext()
        let recipeID = UUID()
        await bgContext.perform {
            let recipe = Recipe(context: bgContext)
            recipe.id = recipeID
            recipe.name = "Bg Recipe"
            recipe.createdAt = Date()
            try! bgContext.save()
        }

        // Wait a moment for merge
        try? await Task.sleep(for: .milliseconds(100))
        let mainFetch: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        mainFetch.predicate = NSPredicate(format: "id == %@", recipeID as CVarArg)
        let results = try! controller.viewContext.fetch(mainFetch)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Bg Recipe")
    }

    func testMergePolicy_IgnoresEmptyProperties() {
        // Save via main
        let mainRecipe = Recipe(context: controller.viewContext)
        mainRecipe.id = UUID()
        mainRecipe.name = "Main"
        mainRecipe.createdAt = Date()
        try! controller.viewContext.save()

        // Background change
        let bg = controller.newBackgroundContext()
        bg.performAndWait {
            let fr: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            fr.predicate = NSPredicate(format: "id == %@", mainRecipe.id as CVarArg)
            let bgRecipe = try! bg.fetch(fr).first!
            bgRecipe.name = "Background Updated"
            try! bg.save()
        }
        Thread.sleep(forTimeInterval: 0.2)
        controller.viewContext.refreshAllObjects()
        let updated = try! controller.viewContext.existingObject(with: mainRecipe.objectID) as! Recipe
        XCTAssertEqual(updated.name, "Background Updated")
    }
}
