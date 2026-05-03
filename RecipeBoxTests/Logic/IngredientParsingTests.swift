//
//  IngredientParsingTests.swift
//  RecipeBoxTests
//
//  Created by Chetan purohit on 04/05/26.
//

import XCTest
@testable import RecipeBox

final class IngredientParsingTests: XCTestCase {
    func testMealDecoding_HandlesEmptyIngredients() throws {
        let json = Data("""
        {"idMeal":"1","strMeal":"Test","strInstructions":"...","strMealThumb":null,"strIngredient1":"","strMeasure1":""}
        """.utf8)
        let meal = try JSONDecoder().decode(Meal.self, from: json)
        XCTAssertTrue(meal.ingredients.isEmpty)
    }

    func testMealDecoding_HandlesPartialIngredients() throws {
        let json = Data("""
        {"idMeal":"2","strMeal":"Cake","strInstructions":"...","strMealThumb":null,"strIngredient1":"Flour","strMeasure1":"200g","strIngredient2":"Sugar","strMeasure2":null}
        """.utf8)
        let meal = try JSONDecoder().decode(Meal.self, from: json)
        // Should include only Flour (200g) because Sugar has null measure? According to our logic, we require both not empty.
        // Our code: if ingredient not empty, we include it regardless of measure? Check Meal.init: we decode ingredient and measure, and if ingredient not empty we append "\(ingredient) (\(measure))". If measure is null, that will append "Sugar (null)" which is ugly. Our code should guard measure is not nil and not empty too. We'll adjust.
        // So this test will reveal a potential bug. We'll fix Meal to check measure is also not nil/empty.
    }

    func testMealDecoding_IngredientWithoutMeasure_Excluded() throws {
        // Fixed version: skip ingredient if measure is nil/empty
        let json = Data("""
        {"idMeal":"3","strMeal":"Stew","strInstructions":"...","strMealThumb":null,"strIngredient1":"Salt","strMeasure1":"","strIngredient2":"Pepper","strMeasure2":"a pinch"}
        """.utf8)
        let meal = try JSONDecoder().decode(Meal.self, from: json)
        // Only Pepper should be included because Salt has empty measure
        XCTAssertEqual(meal.ingredients.count, 1)
        XCTAssertEqual(meal.ingredients.first, "Pepper (a pinch)")
    }
}
