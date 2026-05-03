//
//  RecipeService.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import Foundation
import CoreData

enum RecipeServiceError: Error {
    case badURL, noData, decodingError
}

struct RecipeService {
    static var urlSession = URLSession.shared
    static let baseURL = "https://www.themealdb.com/api/json/v1/1/"

    static func searchRecipes(query: String) async throws -> [Meal] {
        guard let url = URL(string: baseURL + "search.php?s=\(query)") else {
            throw RecipeServiceError.badURL
        }
        let (data, _) = try await self.urlSession.data(from: url)
//        if let jsonString = String(data: data, encoding: .utf8) {
//               print("📄 Raw JSON:\n\(jsonString)")
//           }

        let response = try JSONDecoder().decode(MealSearchResponse.self, from: data)
        return response.meals ?? []
    }

    static func fetchRandomRecipe() async throws -> Meal {
        guard let url = URL(string: baseURL + "random.php") else {
            throw RecipeServiceError.badURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealSearchResponse.self, from: data)
        guard let meal = response.meals?.first else { throw RecipeServiceError.noData }
        return meal
    }
}

struct MealSearchResponse: Codable {
    let meals: [Meal]?
}

struct Meal: Codable, Identifiable {
    let idMeal: String?
    let strMeal: String?
    let strInstructions: String?
    let strMealThumb: String?
    let ingredients: [String]          // e.g. "Chicken - 200g"
    let strCategory: String?
    var id: String { idMeal ?? UUID().uuidString }
    var name: String { strMeal ?? "Unknown" }
    var instructions: String { strInstructions ?? "" }
    var imageURL: URL? {
        guard let str = strMealThumb else { return nil }
        return URL(string: str)
    }

    // Custom decoder to dynamically extract strIngredient1...20 & strMeasure1...20
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        idMeal = try container.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: "idMeal"))
        strMeal = try container.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: "strMeal"))
        strInstructions = try container.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: "strInstructions"))
        strMealThumb = try container.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: "strMealThumb"))
        strCategory = try container.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: "strCategory"))
        var tempIngredients: [String] = []
        for i in 1...20 {
            let ingredientKey = DynamicCodingKeys(stringValue: "strIngredient\(i)")
            let measureKey = DynamicCodingKeys(stringValue: "strMeasure\(i)")

            guard let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey),
                  !ingredient.trimmingCharacters(in: .whitespaces).isEmpty else {
                continue
            }

            // Only add the ingredient if the measure is also present and not empty
            if let measure = try container.decodeIfPresent(String.self, forKey: measureKey),
               !measure.trimmingCharacters(in: .whitespaces).isEmpty {
                tempIngredients.append("\(ingredient) (\(measure))")
            }
        }
        ingredients = tempIngredients
    }

    // For encoding (not used), we can skip or provide a minimal implementation
    func encode(to encoder: Encoder) throws {
        // Not needed for this app
    }
}

// Needed for dynamic keys
struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}

