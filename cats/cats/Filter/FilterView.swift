import SwiftUI
import Combine
enum TagItemStyle {
    case capsule, roundedCorners(cornerRadius: CGFloat)
}
protocol TagList: ObservableObject {
    var items: [TagItem] { get set }
}
class TagHolder: TagList {
    private var disposables = Set<AnyCancellable>()
    @Published var items: [TagItem] = []
    
    init(_ items: [TagItem] = []) {
        self.items = items
    }
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
    var isActive: Bool = true
    
    init(passiveBgColor: Color = Color.gray, activeBgColor: Color, style: TagItemStyle = .capsule, title: String) {
        self.passiveBgColor = passiveBgColor
        self.activeBgColor = activeBgColor
        self.style = style
        self.title = title
    }
}

class FilterViewModel: ObservableObject {
    @Published var attributeModel = TagHolder()
    private var disposables = Set<AnyCancellable>()
    
    func configure(_ breedViewModels: [BreedViewModel]) {
        attributeModel = TagHolder(BreedAttribute.allCases.map { attribute in
                                            return (FilterTag(passiveBgColor: Color.gray, activeBgColor: Color.color(for: attribute), style: .capsule, title: attribute.rawValue))})
        attributeModel.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        }
        ).store(in: &disposables)
    }
}
struct FilterView: View {
    @Binding var viewModel: FilterViewModel
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

