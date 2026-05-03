//
//  CategoryChip.swift
//  RecipeBox
//
//  Created by Chetan purohit on 03/05/26.
//

import SwiftUI

struct CategoryChip: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        Text(name)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "FF6B35") : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : Color(hex: "2C2C2C"))
            .shadow(color: isSelected ? Color(hex: "FF6B35").opacity(0.4) : .clear, radius: 4)
    }
}
