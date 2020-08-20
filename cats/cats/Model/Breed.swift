enum BreedAttributeScale: Int, Decodable {
    case minimal = 1, slightly, neutral, positive, maximal
}
enum BreedAttribute: String {
    case intelligence = "Intelligent", vocalisation = "Vocal", affection = "Affectionate", energy = "Energetic", grooming = "Grooming"
}

struct BreedAttributeRated {
    let attribute: BreedAttribute
    let scale: BreedAttributeScale
}


typealias Breeds = [Breed]
struct BreedImageInfo: Codable, Equatable {
    let imageUrl: String
    let breedId: String
}
struct Breed: Codable, Equatable, Identifiable {
    
    let id: String
    let name: String
    let temperament: [String]
    let description: String
    //let weight: String
    let attributes: [BreedAttributeRated]
    var imageUrl: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, name, temperament, weight, intelligence, vocalisation, affection = "affection_level", energy = "energy_level", grooming, description
    }
    static func == (lhs: Breed, rhs: Breed) -> Bool {
        return lhs.id == rhs.id
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError("encode not implemented")
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
       // weight = try values.decode(String.self, forKey: .weight)

        let temperamentString = try values.decode(String.self, forKey: .temperament)
        temperament = temperamentString.components(separatedBy: ",")

        // Attributes
        let intelligenceRating = try values.decode(BreedAttributeScale.self, forKey: .intelligence)
        let vocalisationRating = try values.decode(BreedAttributeScale.self, forKey: .vocalisation)
        let affectionRating = try values.decode(BreedAttributeScale.self, forKey: .affection)
        let energyRating = try values.decode(BreedAttributeScale.self, forKey: .energy)
        let groomingRating = try values.decode(BreedAttributeScale.self, forKey: .grooming)

        attributes = [
            BreedAttributeRated(attribute: .intelligence, scale: intelligenceRating),
            BreedAttributeRated(attribute: .vocalisation, scale: vocalisationRating),
            BreedAttributeRated(attribute: .affection, scale: affectionRating),
            BreedAttributeRated(attribute: .energy, scale: energyRating),
            BreedAttributeRated(attribute: .grooming, scale: groomingRating)
        ]
    }
    func mainAttribute() -> BreedAttributeRated {
        return attributes.max { a, b in a.scale.rawValue < b.scale.rawValue } ?? maxRatedAttribute()
    }
    private func maxRatedAttribute() -> BreedAttributeRated {
        var currentMax: BreedAttributeRated = BreedAttributeRated(attribute: .intelligence, scale: .minimal)
        attributes.enumerated().forEach { (index, attribute) in
            if index == 0 {
                currentMax = attribute
            }
            if attribute.scale.rawValue > currentMax.scale.rawValue {
                currentMax = attribute
            }
        }
        return currentMax
    }
    func getTemperament() -> String {
        return temperament.map { $0.capitalized }.reduce("", { $0 == "" ? $1 : $0 + "," + $1 })
    }
    
}
