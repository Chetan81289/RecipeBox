//
//  RecipeEntityTests.swift
//  RecipeBoxTests
//
//  Created by Chetan purohit on 04/05/26.
//

import XCTest
import CoreData
@testable import RecipeBox

extension PersistenceController {
    static var testInstance: PersistenceController {
        PersistenceController(inMemory: true)
    }
}


final class RecipeEntityTests: XCTestCase {
    var controller: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        controller = PersistenceController.testInstance
        context = controller.viewContext
    }

    func testCreateRecipe_SetsAttributesCorrectly() {
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = "Test Cake"
        recipe.instructions = "Mix and bake"
        recipe.createdAt = Date()
        XCTAssertNoThrow(try context.save())
        let fetched: [Recipe] = try! context.fetch(Recipe.fetchRequest())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Test Cake")
    }

    func testRecipeID_IsUnique() {
        let r1 = Recipe(context: context); r1.id = UUID()
        let r2 = Recipe(context: context); r2.id = UUID()
        try! context.save()
        let ids = (try! context.fetch(Recipe.fetchRequest())).map(\.id)
        XCTAssertEqual(ids.count, 2)
        XCTAssertNotEqual(ids[0], ids[1])
    }

    func testRecipe_name_DefaultValue() {
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        // name not set -> default from model should be "Untitled"
        try! context.save()
        let fetched = try! context.fetch(Recipe.fetchRequest()).first!
        // The model default we set is "Untitled"
        XCTAssertEqual(fetched.name, "Untitled")
    }

    func testRecipe_sourceURL_Optional() {
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = "No source"
        recipe.createdAt = Date()
        try! context.save()
        XCTAssertNil(recipe.sourceURL)
        recipe.sourceURL = URL(string: "https://example.com")
        try! context.save()
        XCTAssertNotNil(recipe.sourceURL)
    }

    func testDateFormat_CreatedAt() {
        let now = Date()
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.createdAt = now
        try! context.save()
        let fetched = try! context.fetch(Recipe.fetchRequest()).first!
        XCTAssertEqual(fetched.createdAt.timeIntervalSinceReferenceDate,
                       now.timeIntervalSinceReferenceDate,
                       accuracy: 0.001)
    }
}
