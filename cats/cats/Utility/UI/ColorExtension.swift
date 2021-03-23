import SwiftUI
extension Color {
    static let invertedPrimaryText = Color("invertedPrimaryText")
    static let invertedSecondaryText = Color("invertedSecondaryText")
    
    static func color(for attribute: BreedAttribute) -> Color {
        switch attribute {
        case .intelligence:
            return Color(UIColor.systemBlue)
        case .affection:
            return Color(UIColor.systemPink)
        case .energy:
            return Color(UIColor.systemOrange)
        case .grooming:
            return Color(UIColor.systemIndigo)
        case .vocalisation:
            return Color(UIColor.systemGreen)
        }
    }
}
