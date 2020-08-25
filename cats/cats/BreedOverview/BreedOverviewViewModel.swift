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
                self.applyFilters(self.filterModel.attributes.filter { $0.isActive }.map { $0.title }, traitFilters: self.filterModel.traits.filter { $0.isActive }.map { $0.title })
            }
            
        }).store(in: &disposables)
    }
    
    
    private func filterBreeds(_ query: String) {
        guard !query.isEmpty else {
            breeds = allBreeds
            return
        }
        breeds = allBreeds.filter { $0.name.contains(query) }
    }
    private func applyFilters(_ attributeFilters: [String], traitFilters: [String]) {
        guard !attributeFilters.isEmpty || !traitFilters.isEmpty else {
            breeds = allBreeds
            return
        }
        breeds = allBreeds.filter { mainAttributeFilter($0.mainAttribute, filters: attributeFilters)}.filter { Set(traitFilters).isSubset(of: $0.temperaments) }
    }
    private func mainAttributeFilter(_ attribute: String, filters: [String]) -> Bool {
        // When no attribute filters are applied, we want to show breeds of all attributes.
        guard !filters.isEmpty else {
            return true
        }
        // Main category should be a subset of the filters.
        return Set([attribute]).isSubset(of: filters)
    }
    
    /**
     traits: The traits of a specific breed.
     filters: The selected trait filters
     
     returns true when filters is empty or filters is a subset of traits
        
     ---- Example ----
     traits: [A, B, C, D, E]
     filters: [C]
     returns true
     
     filters: [F]
     returns false.
     
     
                
     */
    private func traitFilter(_ traits: [String], filters: [String]) -> Bool {
        guard !filters.isEmpty else {
            return true
        }
        return Set(filters).isSubset(of: Set(traits))
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
