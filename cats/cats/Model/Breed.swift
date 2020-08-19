enum BreedAttributeScale: Int, Decodable {
    case minimal = 1, slightly, neutral, positive, maximal
}
enum BreedAttribute: String {
    case intelligence, vocalisation, affection, energy, grooming
}

struct BreedAttributeRated {
    let attribute: BreedAttribute
    let scale: BreedAttributeScale
}
typealias Breeds = [Breed]
struct Breed: Codable, Equatable, Identifiable {
    
    let id: String
    let name: String
    let temperament: String
    let description: String
    //let weight: String
    let attributes: [BreedAttributeRated]
    
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
        temperament = try values.decode(String.self, forKey: .temperament)
        description = try values.decode(String.self, forKey: .description)
       // weight = try values.decode(String.self, forKey: .weight)

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
    
}
