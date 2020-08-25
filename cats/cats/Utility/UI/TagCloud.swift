import SwiftUI

/*
  Base implementation for TagCloudView provided by Asperi: https://stackoverflow.com/questions/62102647/swiftui-hstack-with-wrap-and-dynamic-height
 
 */

struct TagCloudView<Model>: View where Model: TagList {
    //@ObservedObject var viewModel: ObservableTags
    @ObservedObject var viewModel: Model
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
            ForEach(self.viewModel.items.indices) { index in
                TagItemView(item: $viewModel.items[index])
          //  }
//            ForEach(self.viewModel.items, id: \.self.title) { model in
//                TagItemView(item: $viewModel.items[0])
                //self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if viewModel.items[index].title == self.viewModel.items.last?.title {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if viewModel.items[index].title == self.viewModel.items.last?.title {
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
