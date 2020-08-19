import Combine
import Foundation
class BreedOverviewViewModel: ObservableObject {
    private let breedFetcher: BreedWebRepository = RealBreedWebRepository.shared
    private var disposables = Set<AnyCancellable>()
    
    @Published var breeds: [BreedViewModel] = []
}

// MARK: - Fetching
extension BreedOverviewViewModel {
    func fetchBreeds() {
        breedFetcher.loadFullBreeds()
            .map { (response, info) in
                response.map { breed in
                    return BreedViewModel(breed, imageUrl: info.first(where: { $0.0 == breed.id })?.1 ?? "https://i.pinimg.com/736x/6a/db/be/6adbbe878c012ed1a8802adcc30edd5b.jpg")
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .failure:
                    self.breeds = []
                case .finished: break
                }
                }, receiveValue: { [weak self] breeds in
                    guard let self = self else {
                        return
                    }
                    self.breeds = breeds
                    
            }).store(in: &disposables)
    }
}
