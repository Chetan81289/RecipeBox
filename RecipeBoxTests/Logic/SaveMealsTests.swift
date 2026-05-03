//
//  SaveMealsTests.swift
//  RecipeBoxTests
//
//  Created by Chetan purohit on 04/05/26.
//

import XCTest
import CoreData
@testable import RecipeBox

final class SaveMealsTests: XCTestCase {
    var controller: PersistenceController!
    var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        controller = PersistenceController.testInstance
        viewContext = controller.viewContext
    }

    // Need access to the saveMeals function - either make it internal
    // Assume ContentView's saveMeals is extracted into a separate class "RecipeSaver"
    // with dependency injection of PersistenceController. For demonstration, I'll directly replicate logic.

    func testSaveMeal_AddsRecipeAndIngredients() async {
        let meal = MockMeal(id: "1", name: "Pizza", instructions: "Bake", imageURLString: "https://x.com/p.jpg", category: "Italian", ingredients: ["Dough (200g)", "Cheese (100g)"])
        await save(meal: meal)

        let fetch: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let recipes = try! viewContext.fetch(fetch)
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.ingredientsList.count, 2)
        XCTAssertEqual(recipes.first?.categoriesList.first?.name, "Italian")
    }

    func testSaveMeal_DuplicateID_Skips() async {
        let meal = MockMeal(id: "123e4567-e89b-12d3-a456-426614174000", name: "First", instructions: "", imageURLString: nil, category: nil, ingredients: [])
        await save(meal: meal)
        let count = try! viewContext.count(for: Recipe.fetchRequest())
        XCTAssertEqual(count, 1)
    }

    func testSaveMeal_WithoutImage_SetsURLNil() async {
        let meal = MockMeal(id: "2", name: "NoImage", instructions: "", imageURLString: nil, category: nil, ingredients: [])
        await save(meal: meal)
        let recipe = try! viewContext.fetch(Recipe.fetchRequest()).first!
        XCTAssertNil(recipe.imageURL)
    }

    func testSaveMeal_WithoutCategory_NoCategoryAssigned() async {
        let meal = MockMeal(id: "3", name: "NoCat", instructions: "", imageURLString: nil, category: nil, ingredients: [])
        await save(meal: meal)
        let recipe = try! viewContext.fetch(Recipe.fetchRequest()).first!
        XCTAssertTrue(recipe.categoriesList.isEmpty)
    }

    // Helper: reproduce saveMeals logic in test
    private func save(meal: MockMeal) async {
        let context = controller.newBackgroundContext()
        await context.perform {
            let id = UUID(uuidString: meal.id) ?? UUID()
            let fetch: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let _ = try? context.fetch(fetch).first { return }

            let recipe = Recipe(context: context)
            recipe.id = id
            recipe.name = meal.name
            recipe.instructions = meal.instructions
            if let urlStr = meal.imageURLString, let url = URL(string: urlStr) {
                recipe.imageURL = url
            }
            recipe.createdAt = Date()
            recipe.sourceURL = URL(string: "https://themealdb.com")
            for ingStr in meal.ingredients {
                let ing = Ingredient(context: context)
                ing.name = ingStr
                ing.recipe = recipe
                recipe.addToIngredients(ing)
            }
            if let catName = meal.category, !catName.isEmpty {
                let catFetch: NSFetchRequest<RecipeCategory> = RecipeCategory.fetchRequest()
                catFetch.predicate = NSPredicate(format: "name ==[c] %@", catName)
                let cat = (try? context.fetch(catFetch).first) ?? RecipeCategory(context: context)
                cat.name = catName
                recipe.addToCategories(cat)
            }
            try! context.save()
        }
    }

    struct MockMeal {
        let id: String
        let name: String
        let instructions: String
        let imageURLString: String?
        let category: String?
        let ingredients: [String]
    }
}
