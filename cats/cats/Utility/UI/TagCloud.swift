import SwiftUI

/*
  Base implementation for TagCloudView provided by Asperi: https://stackoverflow.com/questions/62102647/swiftui-hstack-with-wrap-and-dynamic-height
 
 */

struct TagCloudView: View {
    @Binding var viewModel: [TagItem]
    @State private var totalHeight = CGFloat.infinity

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(maxHeight: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(self.viewModel.indices) { index in
                TagItemView(item: $viewModel[index])
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if viewModel[index].title == self.viewModel.last?.title {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if viewModel[index].title == self.viewModel.last?.title {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct TagItemView: View {
    @Binding var item: TagItem
    var backgroundItem: some View {
        switch item.style {
        case .capsule: return AnyView(Capsule().fill(item.isActive ? item.activeBgColor : item.passiveBgColor))
        case .roundedCorners(let radius): return AnyView(RoundedRectangle(cornerRadius: radius).fill(item.isActive ? item.activeBgColor : item.passiveBgColor))
        }
    }
    var body: some View {
        return Text(item.title)
            .padding([.vertical], 5)
            .padding([.horizontal], 10)
            .font(.body)
            .background(backgroundItem).animation(.easeOut)
            .foregroundColor(Color.white)
            .onTapGesture {
                print("Tapped: \(item.title)")
                item.isActive.toggle()
            }
    }
}
