//
//  ContentView.swift
//  T-Gift
//
//  Created by Pavel Korostelev on 21.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isShineVisible = false
    @State private var isGiftPresented = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Button {
                isGiftPresented = true
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
        .sheet(isPresented: $isGiftPresented) {
            GiftModalView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(Color(uiColor: .secondarySystemBackground))
        }
    }
}

struct GiftModalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .center, spacing: 8) {
                    Text("Павел дарит вам подарок")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text("Открывайте скорее!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .hidden()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 32)

                Image("GiftImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
                .safeAreaInset(edge: .bottom) {
                    Button {
                    } label: {
                        Text("Забрать подарок")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
