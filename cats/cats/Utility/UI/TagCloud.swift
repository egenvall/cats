import SwiftUI

/*
  Base implementation for TagCloudView provided by Asperi: https://stackoverflow.com/questions/62102647/swiftui-hstack-with-wrap-and-dynamic-height
 
 */

struct TagCloudView: View {
    @ObservedObject var viewModel: ObservableTags

    @State private var totalHeight
     //     = CGFloat.zero       // << variant for ScrollView/List
       = CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        //.frame(height: totalHeight)// << variant for ScrollView/List
        .frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.viewModel.tags, id: \.self.tag.title) { model in
                TagItemView(item: model)
                //self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if model.tag.title == self.viewModel.tags.last?.tag.title {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if model.tag.title == self.viewModel.tags.last?.tag.title {
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
    @ObservedObject var item: ObservableTagViewModel
    var backgroundItem: some View {
        switch item.tag.style {
        case .capsule: return AnyView(Capsule().fill(item.isActive ? item.tag.activeBgColor : item.tag.passiveBgColor))
        case .roundedCorners(let radius): return AnyView(RoundedRectangle(cornerRadius: radius).fill(item.isActive ? item.tag.activeBgColor : item.tag.passiveBgColor))
        }
    }
    var body: some View {
        return Text(item.tag.title)
            .padding([.vertical], 5)
            .padding([.horizontal], 10)
            .font(.body)
            .background(backgroundItem).animation(.easeOut)
            .foregroundColor(Color.white)
            .onTapGesture {
                print("Tapped: \(item.tag.title)")
                item.isActive.toggle()
            }
    }
}
