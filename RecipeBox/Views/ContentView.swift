//
//  ContentView.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import SwiftUI
import CoreData
import WidgetKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255,0,0,0)
        }
        self.init(
            .sRGB,
            red: Double(r)/255,
            green: Double(g)/255,
            blue: Double(b)/255,
            opacity: Double(a)/255
        )
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var searchText = ""
    @State private var isLoading = false
    @State private var selectedCategory: RecipeCategory?
    @State private var submittedSearch = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "FF6B35").opacity(0.12),
                        Color(hex: "FFF3E0").opacity(0.3),
                        Color(hex: "FAFAFA")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                   // Text("Current search: \(searchText)").font(.caption).foregroundColor(.red)
                    CategoryPicker(selected: $selectedCategory)

                    // The recipe grid (auto‑updates when Core Data changes)
                    RecipeListContainer(searchText: searchText, category: selectedCategory)
                }
            }
            .navigationTitle("RecipeBox")
            .searchable(text: $searchText, prompt: "Find a recipe...")
            .tint(Color(hex: "FF6B35"))
            .onSubmit(of: .search) {
                submittedSearch = searchText
                Task { await fetchAndSaveRecipes() }
            }
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Button {
//                        Task { await fetchAndSaveRecipes() }
//                    } label: {
//                        if isLoading {
//                            ProgressView()
//                        } else {
//                            Image(systemName: "arrow.down.to.line")
//                        }
//                    }
//                    .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
//                }
//            }
            .task {
                // Optionally pre‑load a default receipt on first launch so the app isn’t empty
                if await isDatabaseEmpty() {
                    await fetchDefaultRecipes()
                }
            }
        }
    }

    // MARK: - Networking & persistence

    private func fetchAndSaveRecipes() async {
        isLoading = true
        defer { isLoading = false }
        
        let query = submittedSearch.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        
        do {
            print("🔍 Searching for: \(query)")
            let meals = try await RecipeService.searchRecipes(query: query)
            print("✅ Got \(meals.count) meals from API")
            await saveMeals(meals)
            print("💾 Save completed")
                        // After saving successfully
            
        } catch {
            print("Search failed: \(error)")
            print("❌ API error: \(error.localizedDescription)")
        }
    }

//    private func saveMeals(_ meals: [Meal]) async {
//        let context = PersistenceController.shared.newBackgroundContext()
//        await context.perform {
//            var savedCount = 0
//            for meal in meals {
//                // Use idMeal as UUID to avoid duplicates
//                let id = UUID(uuidString: meal.id) ?? UUID()
//
//                let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//                if let _ = try? context.fetch(fetchRequest).first {
//                    continue // already exists, skip
//                }
//
//                let recipe = Recipe(context: context)
//                recipe.id = id
//                recipe.name = meal.name
//                recipe.instructions = meal.instructions
//                if let urlString = meal.strMealThumb, let url = URL(string: urlString) {
//                    recipe.imageURL = url
//                }
//                recipe.createdAt = Date()
//                // Optionally set sourceURL if available (use a dummy or real)
//                recipe.sourceURL = URL(string: "https://www.themealdb.com")
//                savedCount += 1
//            }
//            if context.hasChanges {
//                do {
//                    try context.save()
//                    print("📦 Saved \(savedCount) new recipes")
//                } catch {
//                    print("Error saving meals: \(error)")
//                    print("🔥 Core Data save error: \(error.localizedDescription)")
//                }
//            } else {
//                print("⚠️ No new recipes to save (already existed)")
//            }
//        }
//    }

    private func saveMeals(_ meals: [Meal]) async {
        let context = PersistenceController.shared.newBackgroundContext()
        await context.perform {
            var savedCount = 0
            for meal in meals {
                let id = UUID(uuidString: meal.idMeal ?? "") ?? UUID()

                let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                // Skip duplicates
                if let existing = try? context.fetch(fetchRequest), !existing.isEmpty { continue }

                let recipe = Recipe(context: context)
                recipe.id = id
                recipe.name = meal.strMeal ?? "Unknown"
                recipe.instructions = meal.strInstructions ?? ""
                if let thumb = meal.strMealThumb, let url = URL(string: thumb) {
                    recipe.imageURL = url
                }
                recipe.createdAt = Date()
                recipe.sourceURL = URL(string: "https://www.themealdb.com")

                // ✅ Create Ingredient entities for each ingredient/measure pair
                for ingredientString in meal.ingredients {
                    let ingredient = Ingredient(context: context)
                    ingredient.name = ingredientString    // Already formatted with measure
                    ingredient.recipe = recipe
                    recipe.addToIngredients(ingredient)   // ensure relationship is set
                }
                
                if let categoryName = meal.strCategory, !categoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                    let catFetchRequest: NSFetchRequest<RecipeCategory> = RecipeCategory.fetchRequest()
                    catFetchRequest.predicate = NSPredicate(format: "name ==[c] %@", categoryName)

                    let recipeCategory: RecipeCategory
                    if let existingCategory = try? context.fetch(catFetchRequest).first {
                        recipeCategory = existingCategory
                    } else {
                        recipeCategory = RecipeCategory(context: context)
                        recipeCategory.name = categoryName
                    }
                    recipe.addToCategories(recipeCategory)
                }

                savedCount += 1
            }

            if context.hasChanges {
                do {
                    try context.save()
                    WidgetCenter.shared.reloadTimelines(ofKind: "RecipeWidget")
                    print("📦 Saved \(savedCount) new recipes with ingredients")
                } catch {
                    print("🔥 Core Data save error: \(error.localizedDescription)")
                }
            } else {
                print("⚠️ No new recipes to save")
            }
        }
    }
    
    private func isDatabaseEmpty() async -> Bool {
        let context = PersistenceController.shared.viewContext
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.fetchLimit = 1
        let count = (try? context.count(for: fetchRequest)) ?? 0
        return count == 0
    }

    private func fetchDefaultRecipes() async {
        // A harmless search that returns a few recipes
        let defaultQuery = ""
        let meals = (try? await RecipeService.searchRecipes(query: defaultQuery)) ?? []
        await saveMeals(meals)
    }
}

struct CategoryPicker: View {
    @FetchRequest(
        entity: RecipeCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RecipeCategory.name, ascending: true)]
    ) private var categories: FetchedResults<RecipeCategory>

    @Binding var selected: RecipeCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(name: "All", isSelected: selected == nil)
                    .onTapGesture { selected = nil }

                ForEach(categories, id: \.self) { cat in
                    CategoryChip(name: cat.name ?? "", isSelected: selected == cat)
                        .onTapGesture { selected = cat }
                }
            }
            .padding(.horizontal)
        }
    }
}
