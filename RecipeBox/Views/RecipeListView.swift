//
//  RecipeListView.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import SwiftUI
import CoreData

// MARK: - Container that rebuilds the fetch when search/category change

import SwiftUI
import CoreData

struct RecipeListContainer: View {
    let searchText: String
    let category: RecipeCategory?

    // Compute the predicate every time searchText or category change
    private var predicate: NSPredicate {
        var predicates = [NSPredicate]()
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        if let cat = category {
            predicates.append(NSPredicate(format: "ANY categories == %@", cat))
        }
        return predicates.isEmpty
            ? NSPredicate(value: true)
            : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        // Recreate FilteredRecipeList only when the predicate changes
        FilteredRecipeList(predicate: predicate)
            .id(predicate.hashValue)   // ✅ forces a re‑init with new FetchRequest
    }
}

// MARK: - The actual list with animations and fetch

struct FilteredRecipeList: View {
    @FetchRequest var recipes: FetchedResults<Recipe>
    @Namespace private var namespace   // for hero animations

    init(predicate: NSPredicate) {
        _recipes = FetchRequest(
            entity: Recipe.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.createdAt, ascending: false)],
            predicate: predicate
        )
    }

    var body: some View {
        ScrollView {
            if recipes.isEmpty {
                ContentUnavailableView("No recipes", systemImage: "fork.knife.circle")
                    .padding(.top, 80)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 20       // 20pt vertical gap – very safe
                ) {
                    ForEach(recipes, id: \.self) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                                .navigationTransition(.zoom(sourceID: recipe.id, in: namespace))
                        } label: {
                            RecipeCard(recipe: recipe)
                                .matchedTransitionSource(id: recipe.id, in: namespace)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .animation(.spring(), value: recipes.count)
    }
}


