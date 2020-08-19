import Combine
import Foundation
class BreedOverviewViewModel: ObservableObject {
    private let breedFetcher: BreedWebRepository = RealBreedWebRepository.shared
    private var disposables = Set<AnyCancellable>()
    
    @Published var breeds: [Breed] = []
}

// MARK: - Fetching
extension BreedOverviewViewModel {
    func fetchBreeds() {
        breedFetcher.loadBreeds()
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
