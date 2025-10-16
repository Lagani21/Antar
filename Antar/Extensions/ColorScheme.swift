//
//  ColorScheme.swift
//  Antar
//
//  Created by Lagani Patel on 10/14/25.
//

import SwiftUI

extension Color {
    // Custom color palette
    static let antarDark = Color(hex: "5a25a4")      // Dark tones
    static let antarBase = Color(hex: "EBDEF7")      // Base color
    static let antarAccent1 = Color(hex: "D144C3")   // Pink accent
    static let antarAccent2 = Color(hex: "DD6031")   // Orange accent
    static let antarAccent3 = Color(hex: "FFD333")   // Yellow accent
    static let antarButton = Color(hex: "F5EFFB")    // Light lavender for buttons
    
    // Convenience initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
