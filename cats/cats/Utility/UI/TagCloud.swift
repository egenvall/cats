import SwiftUI
import Combine
enum TagCloudConfig {
    case stack, scrollable
}

/*
  Base implementation for TagCloudView provided by Asperi: https://stackoverflow.com/questions/62102647/swiftui-hstack-with-wrap-and-dynamic-height
 
 */


struct TagCloudView: View {
    @Binding var viewModel: [TagItem]
    @State private var totalHeight = CGFloat.infinity
    
    var body: some View {
        VStack {
            if viewModel.isEmpty {
                EmptyView()
            }
            else {
                GeometryReader { geometry in
                    self.generateContent(in: geometry)
                }
            }
            
        }
        .frame(height: totalHeight)
    }

    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(self.viewModel, id: \.self.id) { tag in
                let tagIndex = viewModel.firstIndex(where: { $0.id == tag.id })
               
                TagItemView(item: $viewModel[tagIndex!])
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if viewModel[tagIndex!].title == self.viewModel.last?.title {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if viewModel[tagIndex!].title == self.viewModel.last?.title {
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
