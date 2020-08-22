import Combine
import Foundation
import SwiftUI
class BreedOverviewViewModel: ObservableObject {
    private let breedFetcher: BreedWebRepository = RealBreedWebRepository.shared
    private var disposables = Set<AnyCancellable>()
    private let scheduler = DispatchQueue(label: "BreedOverviewModel")
    private var allBreeds: [BreedViewModel] = []
    
    @Published var filterModel: FilterViewModel = FilterViewModel()
    @Published var breeds: [BreedViewModel] = []
    @Published var searchText: String = ""
    @Published var isDisplayingFilter: Bool = false
    
    init() {
        $searchText
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: scheduler)
            .sink(receiveValue: filterBreeds(_:))
            .store(in: &disposables)
        
        filterModel.objectWillChange.sink(receiveValue: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                print("Filter Model Changed")
                self.applyAttributeFilters(self.filterModel.attributeModel.tags.filter { $0.isActive }.map { $0.tag.title })
            }
            
        }).store(in: &disposables)
    }
    
    
    private func filterBreeds(_ query: String) {
        print("Filter with query: \(query)")
        guard !query.isEmpty else {
            breeds = allBreeds
            return
        }
        breeds = allBreeds.filter { $0.name.contains(query) }
    }
    private func applyAttributeFilters(_ attributeFilters: [String]) {
        breeds = allBreeds.filter { Set([$0.mainAttribute]).isSubset(of: attributeFilters)}
    }
    func search(_ query: String) {
        searchText = query
    }
}

// MARK: - Fetching
extension BreedOverviewViewModel {
    func fetchBreeds() {
        breedFetcher.loadFullBreeds()
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
                
                self.filterModel.configure(breeds)
                self.allBreeds = breeds
                self.filterBreeds(self.searchText)
                
            }).store(in: &disposables)
    }
}
