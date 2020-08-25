import SwiftUI
enum TagItemStyle {
    case capsule, roundedCorners(cornerRadius: CGFloat)
}
protocol TagItem {
    var id: UUID { get }
    var passiveBgColor: Color { get }
    var activeBgColor: Color { get }
    var style: TagItemStyle { get }
    var title: String { get }
    var isActive: Bool { get set }
}

struct FilterTag: TagItem {
    var id: UUID = UUID()
    
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
