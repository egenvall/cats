import Combine
final class BreedViewModel: ObservableObject, Identifiable {
    @Published var breed: Breed
    let id: String
    
    init(_ breed: Breed) {
        self.breed = breed
        self.id = breed.id
    }
}
