import SwiftUI
import Combine
struct FilterDetail {
    let title: String
    let message: String
}
struct FilterView: View {
    @ObservedObject var viewModel: FilterViewModel
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                HStack {
                    VStack(alignment: .leading) {
                        Spacer(minLength: 16)
                        FilterSection(title: "Main Attribute",
                                      detail: FilterDetail(title: "Main Attribute",
                                                           message: "Include all breeds whose main attribute is one of the selected")){
                            TagCloudView(viewModel: $viewModel.attributes)
                        }
                        FilterSection(title: "Traits",
                                      detail: FilterDetail(title: "Traits", message: "Include breeds whose traits contains all of the selected & matches eventual main attribute")) {
                            TagCloudView(viewModel: $viewModel.traits)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            .padding([.horizontal]).navigationTitle("Results: \(viewModel.resultCount)")
        }
    }
}


struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    let detail: FilterDetail
    @State var isPresentingDetail: Bool = false
    private var actionSheet: ActionSheet
    
    init(title: String, detail: FilterDetail, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detail = detail
        actionSheet =
            ActionSheet(title: Text(detail.title), message: Text(detail.message), buttons: [
                .default(Text("OK")),
            ])
        self.content = content()
        
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text(title).font(.title).bold()
                Spacer()
                Button(action: {
                    print("Show info for: \(title) - \(detail.message)")
                    isPresentingDetail.toggle()
                    
                    
                }) {
                    Image(systemName: "questionmark.circle")
                }.actionSheet(isPresented: $isPresentingDetail, content: { actionSheet })
                
            }
            content
        }
    }
}

