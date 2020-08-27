import SwiftUI
import Combine

struct FilterView: View {
    @ObservedObject var viewModel: FilterViewModel
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                HStack {
                    VStack(alignment: .leading) {
                        FilterSection(title: "Main Attribute") {
                            TagCloudView(viewModel: $viewModel.attributes)
                        }
                        FilterSection(title: "Traits") {
                            TagCloudView(viewModel: $viewModel.traits)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            .padding().navigationTitle("Results: \(viewModel.resultCount)")
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

