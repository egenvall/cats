import Combine
import SwiftUI
class FilterViewModel: ObservableObject {
    @Published var attributes: [TagItem] = []
    @Published var traits: [TagItem] = []
    @Published var resultCount: Int = 0
    private var disposables = Set<AnyCancellable>()
    
    func configure(_ breedViewModels: [BreedViewModel]) {
        assignMainAttributeFilters(breedViewModels)
        assignTraitFilters(breedViewModels)
    }
    func updateResults(_ results: Int) {
        resultCount = results
    }
}

// MARK: - Main Attributes
extension FilterViewModel {
    private func assignMainAttributeFilters(_ models: [BreedViewModel]) {
        attributes =
            BreedAttribute.allCases.map { attribute in
                return FilterTag(
                    passiveBgColor: Color.gray,
                    activeBgColor: Color.color(for: attribute),
                    style: .capsule, title: attribute.rawValue
                )
            }
    }
}

// MARK: - Traits
extension FilterViewModel {
    private func assignTraitFilters(_ model: [BreedViewModel]) {
        traits =
            Set(model.flatMap { $0.temperaments }).map {
                return FilterTag(
                    passiveBgColor: Color.gray,
                    activeBgColor: Color(UIColor.systemBlue),
                    style: .roundedCorners(cornerRadius: 4), title: $0
                )
            }
    }
}
