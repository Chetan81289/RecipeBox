//
//  Ingredient+CoreDataProperties.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import Foundation
import CoreData

extension Ingredient {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var name: String?
    @NSManaged public var recipe: Recipe?        // inverse of Recipe.ingredients
}

// MARK: - Generated accessors for recipe
extension Ingredient {
    @objc(addRecipeObject:)
    @NSManaged public func addToRecipe(_ value: Recipe)
    
    @objc(removeRecipeObject:)
    @NSManaged public func removeFromRecipe(_ value: Recipe)
    
    @objc(addRecipe:)
    @NSManaged public func addToRecipe(_ values: Set<Recipe>)
    
    @objc(removeRecipe:)
    @NSManaged public func removeFromRecipe(_ values: Set<Recipe>)
    
    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)
    
    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)
    
    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: Set<Ingredient>)
    
    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: Set<Ingredient>)
}
