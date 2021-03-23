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
        return temperaments.reduce("", { $0 == "" ? $1 : $0 + ", " + $1 })
    }
    var temperaments: [String] {
        return breed.temperament.map { $0.capitalized }
    }
    var mainAttribute: String {
        return breed.attributes.max { a, b in a.scale.rawValue < b.scale.rawValue }?.attribute.rawValue ?? maxRatedAttribute
    }
    var mainAttributeColor: Color {
        guard let attribute = BreedAttribute(rawValue: mainAttribute) else {
            return Color(UIColor.systemRed)
        }
        return Color.color(for: attribute)
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
