//
//  CodingKeys.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/10/2024.
//
import SwiftUI

extension Color {
    static func interpolate(from: Color, to: Color, proportion: Double) -> Color {
        let fromComponents = from.components()
        let toComponents = to.components()
        
        let r = fromComponents.red + (toComponents.red - fromComponents.red) * proportion
        let g = fromComponents.green + (toComponents.green - fromComponents.green) * proportion
        let b = fromComponents.blue + (toComponents.blue - fromComponents.blue) * proportion
        
        return Color(red: r, green: g, blue: b)
    }
    
    func components() -> (red: Double, green: Double, blue: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        
        return (red: Double(r), green: Double(g), blue: Double(b))
    }
}

extension Color: Codable {
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
                (a, r, g, b) = (255, 0, 0, 0) // Default to black if input is invalid
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let components = self.cgColor?.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let cgColor = UIColor(self).cgColor
        let components = cgColor.components ?? [0, 0, 0, 0]
        
        try container.encode(components[0], forKey: .red)
        try container.encode(components[1], forKey: .green)
        try container.encode(components[2], forKey: .blue)
        try container.encode(components[3], forKey: .alpha)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let red = try container.decode(CGFloat.self, forKey: .red)
        let green = try container.decode(CGFloat.self, forKey: .green)
        let blue = try container.decode(CGFloat.self, forKey: .blue)
        let alpha = try container.decode(CGFloat.self, forKey: .alpha)
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
}
