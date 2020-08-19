import Combine
final class BreedViewModel: ObservableObject, Identifiable {
    @Published var breed: Breed
    @Published var imageUrl: String
    let id: String
    @Published var isFavourite: Bool = false
    
    init(_ breed: Breed, imageUrl: String) {
        self.breed = breed
        self.id = breed.id
        self.imageUrl = imageUrl
    }
}
