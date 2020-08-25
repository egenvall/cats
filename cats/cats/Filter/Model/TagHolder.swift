import Combine
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
