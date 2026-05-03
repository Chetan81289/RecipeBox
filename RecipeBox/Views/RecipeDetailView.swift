//
//  RecipeDetailView.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) var viewContext
    private var fallbackImage: some View {
        ZStack {
            Color(hex: "FF6B35").opacity(0.2)
            VStack(spacing: 8) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "FF6B35"))
                Text("Could not load image")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                let _ = print("Image URL: \(String(describing: recipe.wrappedImageURL))")
                
                CachedAsyncImage(url: recipe.wrappedImageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                } placeholder: {
                    fallbackImage
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(recipe.wrappedName)
                        .font(.system(.title, design: .serif).bold())
                        .foregroundColor(Color(hex: "2C2C2C"))

                    // Category chips (styled)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recipe.categoriesList, id: \.self) { cat in
                                Text(cat.name ?? "")
                                    .font(.footnote.weight(.medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "2D6A4F").opacity(0.15), in: Capsule())
                                    .foregroundColor(Color(hex: "2D6A4F"))
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Ingredients section with coloured icons
                VStack(alignment: .leading, spacing: 8) {
                    Label("Ingredients", systemImage: "list.bullet.rectangle")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "2C2C2C"))

                    ForEach(recipe.ingredientsList, id: \.self) { ing in
                        HStack {
                            Circle()
                                .fill(Color(hex: "FF6B35"))
                                .frame(width: 8, height: 8)
                            Text(ing.name ?? "")
                                .foregroundColor(Color(hex: "7B5E57"))
                        }
                    }
                }
                .padding(.horizontal)

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Label("Instructions", systemImage: "text.book.closed")
                        .font(.title2.bold())
                    Text(recipe.wrappedInstructions)
                        .font(.body)
                        .lineSpacing(6)
                        .foregroundColor(Color(hex: "2C2C2C"))
                }
                .padding(.horizontal)

                if let sourceURL = recipe.sourceURL {
                    Link(destination: sourceURL) {
                        HStack {
                            Image(systemName: "safari")
                            Text("View Original Recipe")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "FF6B35"), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(hex: "FAFAFA").ignoresSafeArea())
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .animation(.spring(), value: recipe)
    }
}
