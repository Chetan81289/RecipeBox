//
//  RecipeServiceTests.swift
//  RecipeBoxTests
//
//  Created by Chetan purohit on 04/05/26.
//

import XCTest
@testable import RecipeBox

final class RecipeServiceTests: XCTestCase {
    let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }()
   
    override func setUp() {
        RecipeService.urlSession = session
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testSearchRecipes_Success() async throws {
        let json = """
        {"meals":[{"idMeal":"1","strMeal":"Test","strInstructions":"Do it","strMealThumb":"https://x.com/a.jpg","strCategory":"Dessert","strIngredient1":"Sugar","strMeasure1":"1 cup"}]}
        """
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }
        // Override session in RecipeService (requires slight refactor to inject session)
        // Alternatively, write testable method: RecipeService internally uses URLSession.shared; we can't easily mock.
        // For testability, add an internal `static var urlSession = URLSession.shared` and replace in tests.
        // I'll assume we added that.
        RecipeService.urlSession = session
        let meals = try await RecipeService.searchRecipes(query: "test")
        XCTAssertEqual(meals.count, 1)
        XCTAssertEqual(meals.first?.name, "Test")
        XCTAssertEqual(meals.first?.ingredients.count, 1)
        XCTAssertTrue(meals.first?.ingredients.contains("Sugar (1 cup)") ?? false)
        XCTAssertEqual(meals.first?.strCategory, "Dessert")
    }

    func testSearchRecipes_EmptyResult() async throws {
        let json = "{\"meals\":null}"
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data(json.utf8))
        }
        RecipeService.urlSession = session
        let meals = try await RecipeService.searchRecipes(query: "nothing")
        XCTAssertTrue(meals.isEmpty)
    }

    func testSearchRecipes_NetworkError() async {
        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }
        RecipeService.urlSession = session
        do {
            _ = try await RecipeService.searchRecipes(query: "x")
            XCTFail("Should have thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testMealDecoding_HandlesMissingCategory() async throws {
        let json = """
        {"meals":[{"idMeal":"2","strMeal":"NoCat","strInstructions":"...","strMealThumb":"https://x.com/b.jpg"}]}
        """
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data(json.utf8))
        }
        RecipeService.urlSession = session
        let meals = try await RecipeService.searchRecipes(query: "y")
        XCTAssertEqual(meals.first?.strCategory, nil)
    }
}
