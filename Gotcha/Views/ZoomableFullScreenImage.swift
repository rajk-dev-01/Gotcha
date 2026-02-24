//
//  ZoomableFullScreenImage.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/26/25.
//

import SwiftUI

struct ZoomableFullScreenImage: View {
    let image: UIImage
    @Binding var fullScreenImage: Bool
    @State var currentScale: CGFloat = 1.0
    @State var lastScale: CGFloat = 1.0
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(currentScale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in currentScale = lastScale * value }
                                .onEnded { _ in lastScale = currentScale },
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height)
                                }
                                .onEnded { _ in lastOffset = offset }
                        )
                    )
            }
            .onTapGesture { fullScreenImage = false }
        }
    }
}
