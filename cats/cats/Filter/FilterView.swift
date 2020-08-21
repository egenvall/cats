import SwiftUI
enum TagItemStyle {
    case capsule, roundedCorners(cornerRadius: CGFloat)
}
protocol TagItem {
    var passiveBgColor: Color { get }
    var activeBgColor: Color { get }
    var style: TagItemStyle { get }
    var title: String { get }
    var isActive: Bool { get set }
}

struct FilterTag: TagItem {
    var passiveBgColor: Color
    var activeBgColor:  Color
    var style: TagItemStyle
    var title: String
    var isActive: Bool = false
    
    init(passiveBgColor: Color = Color.gray, activeBgColor: Color, style: TagItemStyle = .capsule, title: String) {
        self.passiveBgColor = passiveBgColor
        self.activeBgColor = activeBgColor
        self.style = style
        self.title = title
    }
}
class ObservableTagViewModel: ObservableObject, Hashable {
    static func == (lhs: ObservableTagViewModel, rhs: ObservableTagViewModel) -> Bool {
        return lhs.tag.title == rhs.tag.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag.title)
    }
    
    @Published var tag: TagItem
    @Published var isActive: Bool = false
    init(_ tag: TagItem) {
        self.tag = tag
    }
}
class ObservableTags: ObservableObject {
    @Published var tags: [ObservableTagViewModel]
    init(_ tags: [ObservableTagViewModel]) {
        self.tags = tags
    }
}
class FilterViewModel: ObservableObject {
    @Published var attributeModel: ObservableTags
    
    init(_ breedViewModels: [BreedViewModel]) {
        
        
        attributeModel = ObservableTags(BreedAttribute.allCases.map { attribute in
                                            return ObservableTagViewModel(FilterTag(passiveBgColor: Color.gray, activeBgColor: Color.color(for: attribute), style: .capsule, title: attribute.rawValue))}
        )
    }
}
struct FilterView: View {
    @ObservedObject var viewModel: FilterViewModel
    var body: some View {
        NavigationView {
            HStack {
                VStack(alignment: .leading) {
                    FilterSection(title: "Main Attribute") {
                        TagCloudView(viewModel: viewModel.attributeModel)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding().navigationTitle("Filter")
        }
    }
    init(_ breedViewModels: [BreedViewModel]) {
        self.viewModel = FilterViewModel(breedViewModels)
    }
}
struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.title).bold()
            content
        }
    }
}

