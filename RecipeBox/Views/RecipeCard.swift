//
//  RecipeCard.swift
//  RecipeBox
//
//  Created by Chetan purohit on 03/05/26.
//

import SwiftUI

struct RecipeCard: View {
    @ObservedObject var recipe: Recipe

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background placeholder – always occupies the full card
            Color(.systemGray5)
            
            // Image that never leaks out
            if let url = recipe.wrappedImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        fallbackImage
                    @unknown default:
                        fallbackImage
                    }
                }
                // These two lines are the secret:
                .aspectRatio(1, contentMode: .fill)   // force square‑ish ratio to match card height
                .frame(maxWidth: .infinity, maxHeight: .infinity) // fill the ZStack completely
            } else {
                fallbackImage
            }

            // Gradient stays inside the card
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.wrappedName)
                    .font(.system(.headline, design: .serif).weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 2)

                if !recipe.categoriesList.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(recipe.categoriesList.prefix(2), id: \.self) { cat in
                            Text(cat.name ?? "")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.ultraThinMaterial, in: Capsule())
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(12)
        }
        // FIXED HEIGHT – never changes
        .frame(height: 200)
        // Clip everything to the rounded shape (this also clips the image)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "FF6B35").opacity(0.15), radius: 8, x: 0, y: 4)
        
    }

    private var fallbackImage: some View {
        ZStack {
            Color(hex: "FF6B35").opacity(0.2)
            Image(systemName: "fork.knife")
                .font(.system(size: 30))
                .foregroundColor(Color(hex: "FF6B35"))
        }
    }
}
