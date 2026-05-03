//
//  RecipeCategory+CoreDataProperties.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import Foundation
import CoreData

extension RecipeCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeCategory> {
        return NSFetchRequest<RecipeCategory>(entityName: "RecipeCategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var recipes: Set<Recipe>?  // inverse of Recipe.categories
}

// MARK: - Generated accessors for recipes
extension RecipeCategory {
    @objc(addRecipesObject:)
    @NSManaged public func addToRecipes(_ value: Recipe)

    @objc(removeRecipesObject:)
    @NSManaged public func removeFromRecipes(_ value: Recipe)

    @objc(addRecipes:)
    @NSManaged public func addToRecipes(_ values: Set<Recipe>)

    @objc(removeRecipes:)
    @NSManaged public func removeFromRecipes(_ values: Set<Recipe>)
}
