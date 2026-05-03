//
//  ShimmerView.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 03/05/26.
//

import SwiftUI

struct ShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.linearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.6), .gray.opacity(0.3)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing))
            .overlay(
                GeometryReader { proxy in
                    Color.white
                        .mask(
                            Rectangle()
                                .fill(.linearGradient(colors: [.clear, .white.opacity(0.3), .clear],
                                                      startPoint: .leading,
                                                      endPoint: .trailing))
                                .rotationEffect(.degrees(30))
                                .offset(x: -proxy.size.width + phase * (proxy.size.width * 2))
                        )
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}
