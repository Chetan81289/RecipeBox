//
//  CachedAsyncImage.swift
//  RecipeBox
//
//  Created by Chetan purohit on 03/05/26.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var phase: Phase = .loading

    enum Phase {
        case loading
        case success(Image)
        case failure
    }

    var body: some View {
        Group {
            switch phase {
            case .loading:
                placeholder()
                    .overlay(ProgressView().tint(.orange))
            case .success(let image):
                content(image)
            case .failure:
                placeholder()
            }
        }
        .task {
            guard let url = url else {
                phase = .failure
                return
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    phase = .success(Image(uiImage: uiImage))
                } else {
                    phase = .failure
                }
            } catch {
                phase = .failure
            }
        }
    }
}
