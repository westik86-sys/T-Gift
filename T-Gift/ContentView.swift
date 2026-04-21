//
//  ContentView.swift
//  T-Gift
//
//  Created by Pavel Korostelev on 21.04.2026.
//

import SwiftUI
import UIKit

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
    private let shockwaveColor = Color(red: 248.0 / 255.0, green: 116.0 / 255.0, blue: 133.0 / 255.0)
    @State private var giftShakeOffset: CGFloat = 0
    @State private var giftShakeRotation = 0.0
    @State private var giftScale = 1.0
    @State private var giftOpacity = 1.0
    @State private var contentOpacity = 1.0
    @State private var shockwaveScale = 0.05
    @State private var shockwaveOpacity = 0.0
    @State private var shockwaveLineWidth: CGFloat = 12
    @State private var isOpeningGift = false
    @State private var hasOpenedGift = false

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
                .opacity(contentOpacity)

                ZStack {
                    Circle()
                        .stroke(shockwaveColor.opacity(shockwaveOpacity), lineWidth: shockwaveLineWidth)
                        .frame(width: 120, height: 120)
                        .scaleEffect(shockwaveScale)
                        .blur(radius: 10)
                        .blendMode(.screen)
                        .allowsHitTesting(false)

                    if !hasOpenedGift {
                        ZStack {
                            Image("GiftImage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .blur(radius: 32)
                                .opacity(0.28)
                                .scaleEffect(1.2)

                            Image("GiftImage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)

                            SparkleOverlay()
                                .frame(width: 300, height: 300)
                                .allowsHitTesting(false)
                        }
                        .opacity(giftOpacity)
                        .scaleEffect(giftScale)
                        .rotationEffect(.degrees(giftShakeRotation))
                        .offset(x: giftShakeOffset)
                    }
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        try? await Task.sleep(for: .seconds(1))

                        while !Task.isCancelled {
                            guard !Task.isCancelled else {
                                return
                            }

                            if !isOpeningGift {
                                await shakeGiftImage()
                            }

                            try? await Task.sleep(for: .seconds(3))
                        }
                    }
            }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        Task {
                            await startGiftOpening()
                        }
                    } label: {
                        Text("Открыть")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .opacity(contentOpacity)
                    .allowsHitTesting(!isOpeningGift)
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

    @MainActor
    private func shakeGiftImage() async {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        haptic.impactOccurred(intensity: 0.75)

        await animateGiftShake(offset: 6, rotation: 2.5)
        await animateGiftShake(offset: -6, rotation: -2.5)
        await animateGiftShake(offset: 4, rotation: 1.6)
        await animateGiftShake(offset: -4, rotation: -1.6)
        await animateGiftShake(offset: 0, rotation: 0)
    }

    @MainActor
    private func startGiftOpening() async {
        guard !isOpeningGift else {
            return
        }

        isOpeningGift = true
        let shrinkDuration = 0.9

        withAnimation(.easeInOut(duration: 0.35)) {
            contentOpacity = 0
        }

        withAnimation(.easeInOut(duration: shrinkDuration)) {
            giftScale = 0.42
        }

        await shakeGiftImageStrongly(duration: shrinkDuration, resetAtEnd: false)
        await explodeGift()
    }

    @MainActor
    private func explodeGift() async {
        let haptic = UINotificationFeedbackGenerator()
        haptic.prepare()
        let explosionDuration = 0.58

        shockwaveScale = 0.05
        shockwaveOpacity = 0.95
        shockwaveLineWidth = 1
        haptic.notificationOccurred(.success)

        withAnimation(.easeOut(duration: explosionDuration)) {
            giftScale = 2.1
            giftOpacity = 0
            shockwaveScale = 7.2
            shockwaveOpacity = 0
            shockwaveLineWidth = 90
        }

        await shakeGiftImageStrongly(duration: explosionDuration)
        hasOpenedGift = true
    }

    @MainActor
    private func shakeGiftImageStrongly(duration: TimeInterval, resetAtEnd: Bool = true) async {
        let haptic = UIImpactFeedbackGenerator(style: .heavy)
        haptic.prepare()
        let endDate = Date().addingTimeInterval(duration)

        let frames: [(offset: CGFloat, rotation: Double)] = [
            (16, 7),
            (-16, -7),
            (14, 6),
            (-14, -6),
            (12, 5),
            (-12, -5),
            (9, 4),
            (-9, -4),
            (0, 0)
        ]

        while Date() < endDate {
            for (index, frame) in frames.enumerated() {
                guard Date() < endDate else {
                    break
                }

                if index.isMultiple(of: 2) {
                    haptic.impactOccurred(intensity: 0.9)
                    haptic.prepare()
                }

                await animateGiftShake(
                    offset: frame.offset,
                    rotation: frame.rotation,
                    duration: 0.045
                )
            }
        }

        if resetAtEnd {
            await animateGiftShake(offset: 0, rotation: 0, duration: 0.045)
        }
    }

    @MainActor
    private func animateGiftShake(offset: CGFloat, rotation: Double, duration: Double = 0.07) async {
        withAnimation(.easeInOut(duration: duration)) {
            giftShakeOffset = offset
            giftShakeRotation = rotation
        }

        try? await Task.sleep(for: .seconds(duration))
    }
}

struct SparkleOverlay: View {
    private let particles = SparkleParticle.baseSet()
    private let sparkleDuration = 2.4

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                context.addFilter(.blur(radius: 1))

                for particle in particles {
                    let phase = sparklePhase(time: time, delay: particle.delay)
                    let cycle = sparkleCycle(time: time, delay: particle.delay)
                    let opacity = sin(phase * .pi)

                    guard opacity > 0 else {
                        continue
                    }

                    let particleSize = particleSize(for: particle, cycle: cycle)
                    let center = CGPoint(
                        x: size.width * particleX(for: particle, cycle: cycle),
                        y: size.height * particleY(for: particle, cycle: cycle)
                    )
                    let length = particleSize * (0.8 + opacity * 1.4)
                    let diagonalLength = length * 0.45
                    let lineWidth = max(0.8, particleSize * 0.12)

                    var path = Path()
                    path.move(to: CGPoint(x: center.x - length, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + length, y: center.y))
                    path.move(to: CGPoint(x: center.x, y: center.y - length))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + length))
                    path.move(to: CGPoint(x: center.x - diagonalLength, y: center.y - diagonalLength))
                    path.addLine(to: CGPoint(x: center.x + diagonalLength, y: center.y + diagonalLength))
                    path.move(to: CGPoint(x: center.x - diagonalLength, y: center.y + diagonalLength))
                    path.addLine(to: CGPoint(x: center.x + diagonalLength, y: center.y - diagonalLength))

                    context.stroke(
                        path,
                        with: .color(.white.opacity(0.75 * opacity)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                    let glowRect = CGRect(
                        x: center.x - length,
                        y: center.y - length,
                        width: length * 2,
                        height: length * 2
                    )

                    context.fill(
                        Path(ellipseIn: glowRect),
                        with: .color(.white.opacity(0.12 * opacity))
                    )

                    let coreRect = CGRect(
                        x: center.x - particleSize * 0.22,
                        y: center.y - particleSize * 0.22,
                        width: particleSize * 0.44,
                        height: particleSize * 0.44
                    )

                    context.fill(
                        Path(ellipseIn: coreRect),
                        with: .color(.white.opacity(0.9 * opacity))
                    )
                }
            }
        }
    }

    private func sparklePhase(time: TimeInterval, delay: Double) -> Double {
        ((time + delay).truncatingRemainder(dividingBy: sparkleDuration)) / sparkleDuration
    }

    private func sparkleCycle(time: TimeInterval, delay: Double) -> Int {
        Int(floor((time + delay) / sparkleDuration))
    }

    private func particleX(for particle: SparkleParticle, cycle: Int) -> Double {
        0.14 + seededUnit(seed: particle.seed, cycle: cycle, salt: 11) * 0.72
    }

    private func particleY(for particle: SparkleParticle, cycle: Int) -> Double {
        0.16 + seededUnit(seed: particle.seed, cycle: cycle, salt: 29) * 0.68
    }

    private func particleSize(for particle: SparkleParticle, cycle: Int) -> CGFloat {
        3 + CGFloat(seededUnit(seed: particle.seed, cycle: cycle, salt: 47)) * 3
    }

    private func seededUnit(seed: Int, cycle: Int, salt: Int) -> Double {
        let value = sin(Double(seed * 12_989 + cycle * 78_233 + salt * 37_719)) * 43_758.5453
        return value - floor(value)
    }
}

struct SparkleParticle {
    let seed: Int
    let delay: Double

    static func baseSet(count: Int = 8) -> [SparkleParticle] {
        (0..<count).map { index in
            SparkleParticle(
                seed: index + 1,
                delay: Double(index) * 0.27
            )
        }
    }
}

#Preview {
    ContentView()
}
