//
//  Recipe+CoreDataProperties.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import Foundation
import CoreData

extension Recipe {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var instructions: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var sourceURL: URL?
    @NSManaged public var createdAt: Date
    @NSManaged public var ingredients: Set<Ingredient>?
    @NSManaged public var categories: Set<RecipeCategory>?

    public var wrappedName: String { name }
    public var wrappedInstructions: String { instructions ?? "" }
    public var wrappedImageURL: URL? { imageURL }
    public var wrappedCreatedAt: Date { createdAt }
    
    public var ingredientsList: [Ingredient] {
        let set = ingredients as? Set<Ingredient> ?? []
        return Array(set).sorted { (a: Ingredient, b: Ingredient) -> Bool in (a.name ?? "") < (b.name ?? "") }
    }

    public var categoriesList: [RecipeCategory] {
        let set = categories as? Set<RecipeCategory> ?? []
        return Array(set).sorted { (a: RecipeCategory, b: RecipeCategory) -> Bool in (a.name ?? "") < (b.name ?? "") }
    }
}

// MARK: - Generated accessors for ingredients
extension Recipe {
    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: Set<Ingredient>)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: Set<Ingredient>)
    
    @objc(addCategoriesObject:)
       @NSManaged public func addToCategories(_ value: RecipeCategory)

       @objc(removeCategoriesObject:)
       @NSManaged public func removeFromCategories(_ value: RecipeCategory)

       @objc(addCategories:)
       @NSManaged public func addToCategories(_ values: Set<RecipeCategory>)

       @objc(removeCategories:)
       @NSManaged public func removeFromCategories(_ values: Set<RecipeCategory>)
}

// Similar for categories (omitted for brevity)
