import Combine
import Foundation
import SwiftUI
class BreedOverviewViewModel: ObservableObject {
    private let breedFetcher: BreedWebRepository = RealBreedWebRepository.shared
    private var disposables = Set<AnyCancellable>()
    private let scheduler = DispatchQueue(label: "BreedOverviewModel")
    private var allBreeds: [BreedViewModel] = []
    @Published var breeds: [BreedViewModel] = []
    @Published var searchText: String = ""
    
    init() {
        $searchText
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: scheduler)
            .sink(receiveValue: filterBreeds(_:))
            .store(in: &disposables)
    }
    
    private func filterBreeds(_ query: String) {
        print("Filter with query: \(query)")
        guard !query.isEmpty else {
            breeds = allBreeds
            return
        }
        breeds = allBreeds.filter { $0.breed.name.contains(query) }
    }
    func search(_ query: String) {
        searchText = query
    }
}

// MARK: - Fetching
extension BreedOverviewViewModel {
    func fetchBreeds() {
        breedFetcher.loadFullBreeds()
//            .map { (response, info) in
//                response.map { breed in
//                    return BreedViewModel(breed, imageUrl: info.first(where: { $0.breedId == breed.id })?.imageUrl ?? "https://i.pinimg.com/736x/6a/db/be/6adbbe878c012ed1a8802adcc30edd5b.jpg")
//                }
//            }
            .map { response in
                return response.map { BreedViewModel($0)}
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
                    self.allBreeds = breeds
                    self.filterBreeds(self.searchText)
                    
            }).store(in: &disposables)
    }
}
