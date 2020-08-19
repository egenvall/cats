import Combine
final class BreedViewModel: ObservableObject, Identifiable {
    @Published var breed: Breed
    let id: String
    @Published var isFavourite: Bool = false
    
    init(_ breed: Breed) {
        self.breed = breed
        self.id = breed.id
    }
}
