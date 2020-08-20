import SwiftUI
import SwiftlySearch
struct ContentView: View {
    @ObservedObject var viewModel = BreedOverviewViewModel()
    var layout = [ GridItem(.flexible()) ]
    @State var searchText = ""
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: layout, spacing: 20) {
                    ForEach(viewModel.breeds.filter {
                        return searchText.isEmpty ? true : $0.breed.name.contains(searchText)
                        
                    }) {
                        BreedItemView(viewModel: $0)
                    }
                }.padding().animation(.easeOut)
            }.onAppear(perform: {
                self.viewModel.fetchBreeds()
            }).navigationTitle("Breeds").navigationBarSearch(self.$searchText)
        }
    }
}

extension ContentView {
    var searchView: some View {
        HStack(alignment: .center) {
            TextField("e.g. Russian Blue", text: $viewModel.searchText)
        }
    }
}

struct BreedTemperamentView: View {
    let temperament: String
    var body: some View {
        Text(temperament).padding(5).lineLimit(1).background(Color(UIColor.systemBlue)).cornerRadius(8).foregroundColor(.white)
    }
}

struct MainAttributeView: View {
    let attribute: BreedAttributeRated
    
    var body: some View {
        Text(attribute.attribute.rawValue.capitalized)
            .font(.subheadline)
            .bold()
            .padding([.vertical], 5)
            .padding([.horizontal], 15)
            .foregroundColor(.white)
            .background(getColor())
            .cornerRadius(50) // Abnormally high makes them round
    }
    
    private func getColor() -> Color {
        switch attribute.attribute {
        case .intelligence:
            return Color(UIColor.systemBlue)
        case .affection:
            return Color(UIColor.systemPink)
        case .energy:
            return Color(UIColor.systemOrange)
        case .grooming:
            return Color(UIColor.systemIndigo)
        case .vocalisation:
            return Color(UIColor.systemGreen)
        }
    }
}

struct BreedItemView: View {
    @ObservedObject var viewModel: BreedViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color(UIColor.systemBackground)).shadow(radius: 4.0)
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(viewModel.breed.name).font(.title).bold()
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        MainAttributeView(attribute: viewModel.breed.mainAttribute()).fixedSize()

                    }
                    Rectangle().fill(Color(UIColor.separator)).frame(height: 1)
                    
                    Text(viewModel.breed.getTemperament()).font(.subheadline).foregroundColor(Color(UIColor.secondaryLabel)).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                }
                Spacer()
            }.padding()
        }
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
