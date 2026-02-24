//
//  AppTheme.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 1/28/26.
//

import SwiftUI

struct AppTheme {
    static let brandGreenLight = Color(hex: "A4EB14")
    static let brandGreenDark = Color(hex: "5E8C22")
    static let deepText = Color(hex: "1C1C1E")
    static let mainBackground = LinearGradient(
        gradient: Gradient(colors: [brandGreenLight, brandGreenDark]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension View {
    func brandFont(size: CGFloat? = nil, weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: size ?? 17, weight: weight, design: .rounded))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
