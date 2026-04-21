//
//  ContentView.swift
//  T-Gift
//
//  Created by Pavel Korostelev on 21.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isShineVisible = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Button {
            } label: {
                Label("Получить подарок", systemImage: "gift.fill")
                    .font(.headline)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(.white.opacity(0.18))
            .foregroundStyle(.white)
            .overlay {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.06),
                                        .white.opacity(0.42),
                                        .white.opacity(0.06),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: max(44, width * 0.28), height: height * 2.4)
                            .blur(radius: 24)
                            .rotationEffect(.degrees(22))
                            .offset(x: isShineVisible ? width * 0.85 : -width * 0.85)
                            .blendMode(.screen)
                    }
                    .frame(width: width, height: height)
                }
                .clipShape(Capsule())
                .allowsHitTesting(false)
            }
            .clipShape(Capsule())
            .onAppear {
                Task {
                    while !Task.isCancelled {
                        isShineVisible = false

                        try? await Task.sleep(for: .seconds(0.15))

                        withAnimation(.easeInOut(duration: 0.9)) {
                            isShineVisible = true
                        }

                        try? await Task.sleep(for: .seconds(3))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
