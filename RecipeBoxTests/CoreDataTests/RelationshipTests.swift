//
//  RelationshipTests.swift
//  RecipeBoxTests
//
//  Created by Chetan purohit on 04/05/26.
//

import XCTest
import CoreData
@testable import RecipeBox

final class RelationshipTests: XCTestCase {
    var controller: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        controller = PersistenceController.testInstance
        context = controller.viewContext
    }

    // Recipe-Ingredient
    func testAddIngredient_ToRecipe() {
        let recipe = createRecipe("Pasta")
        let ingredient = Ingredient(context: context)
        ingredient.name = "Tomato"
        ingredient.recipe = recipe
        // Also add to recipe set for bidirectional
        recipe.addToIngredients(ingredient)
        try! context.save()

        XCTAssertEqual(recipe.ingredients?.count, 1)
        XCTAssertEqual(ingredient.recipe, recipe)
        XCTAssertTrue(recipe.ingredientsList.contains(where: { $0.name == "Tomato" }))
    }

    func testDeleteRecipe_CascadesToIngredients() {
        let recipe = createRecipe("Salad")
        let ing = Ingredient(context: context); ing.name = "Lettuce"; ing.recipe = recipe
        recipe.addToIngredients(ing)
        try! context.save()
        context.delete(recipe)
        try! context.save()
        let fetch: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        let ingredients = try! context.fetch(fetch)
        XCTAssertTrue(ingredients.isEmpty, "Ingredients should be deleted with cascade")
    }

    // Recipe-Category (many-to-many)
    func testRecipe_CanHaveMultipleCategories() {
        let recipe = createRecipe("Curry")
        let cat1 = RecipeCategory(context: context); cat1.name = "Indian"
        let cat2 = RecipeCategory(context: context); cat2.name = "Spicy"
        recipe.addToCategories(cat1)
        recipe.addToCategories(cat2)
        try! context.save()
        XCTAssertEqual(recipe.categories?.count, 2)
        XCTAssertTrue(cat1.recipes?.contains(recipe) ?? false)
    }

    func testDeleteCategory_DoesNotDeleteRecipe() {
        let recipe = createRecipe("Pie")
        let cat = RecipeCategory(context: context); cat.name = "Dessert"
        recipe.addToCategories(cat)
        try! context.save()
        context.delete(cat)
        try! context.save()
        let fetch: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let recipes = try! context.fetch(fetch)
        XCTAssertEqual(recipes.count, 1, "Nullify should not delete recipe")
    }

    // Helper
    private func createRecipe(_ name: String) -> Recipe {
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = name
        recipe.createdAt = Date()
        return recipe
    }
}
