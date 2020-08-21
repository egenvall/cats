import Combine
import SwiftUI
final class BreedViewModel: ObservableObject, Identifiable {
    private let breed: Breed
    
    var id: String {
        return breed.id
    }
    var name: String {
        return breed.name
    }
    var temperamentDescription: String {
        let capitalized = breed.temperament.map { $0.capitalized }
        return capitalized.reduce("", { $0 == "" ? $1 : $0 + "," + $1 })
    }
    
    var mainAttribute: String {
        return breed.attributes.max { a, b in a.scale.rawValue < b.scale.rawValue }?.attribute.rawValue ?? maxRatedAttribute
    }
    var mainAttributeColor: Color {
        guard let attribute = BreedAttribute(rawValue: mainAttribute) else {
            return Color(UIColor.systemRed)
        }
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
    
    private var maxRatedAttribute: String {
        var currentMax: BreedAttributeRated = BreedAttributeRated(attribute: .intelligence, scale: .minimal)
        breed.attributes.enumerated().forEach { (index, attribute) in
            if index == 0 {
                currentMax = attribute
            }
            if attribute.scale.rawValue > currentMax.scale.rawValue {
                currentMax = attribute
            }
        }
        return currentMax.attribute.rawValue
    }
    init(_ breed: Breed) {
        self.breed = breed
    }
}
