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
        breedFetcher.loadBreeds()
            .map { response in
                response.map { BreedViewModel($0) }
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
