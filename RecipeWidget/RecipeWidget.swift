//
//  RecipeWidget.swift
//  RecipeWidget
//
//  Created by Jyoti Purohit on 03/05/26.
//

import SwiftUI
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

struct RecipeWidgetEntryView: View {
    var entry: RecipeWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }
    
    // MARK: - Small widget (square)
    private var smallWidget: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image (full bleed)
            if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback gradient when no image
                LinearGradient(
                    colors: [Color(hex: "FF6B35"), Color(hex: "FF6B35").opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // Dark overlay for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.recipeName)
                    .font(.system(.headline, design: .serif).weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 2)
                
                if let category = entry.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundColor(.white)
                }
            }
            .padding(12)
        }
        .widgetURL(URL(string: "recipebox://recipe/\(entry.recipeName)"))
    }
    
    // MARK: - Medium widget (wider)
    private var mediumWidget: some View {
        HStack(alignment: .center, spacing: 0) {
            // Left image (takes 40% width)
            if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130)
                    .clipped()
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "FF6B35"), Color(hex: "FF6B35").opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 130)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
            
            // Right text area (60% width)
            VStack(alignment: .leading, spacing: 12) {
                Text(entry.recipeName)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                if let category = entry.category {
                    Text(category)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "FF6B35").opacity(0.15), in: Capsule())
                        .foregroundColor(Color(hex: "FF6B35"))
                }
                
                Spacer()
                
                // Small decorative text
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("Tap to view recipe")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            .padding(.leading, 16)
            .padding(.vertical, 16)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)   // small inset from screen edges
        .widgetURL(URL(string: "recipebox://recipe/\(entry.recipeName)"))
    }
}

struct RecipeWidget: Widget {
    let kind: String = "RecipeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecipeWidgetProvider()) { entry in
            RecipeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today’s Recipe")
        .description("Shows your most recently saved recipe.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
