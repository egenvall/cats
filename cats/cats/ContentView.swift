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

struct BreedItemView: View {
    @ObservedObject var viewModel: BreedViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color(UIColor.systemBackground)).shadow(radius: 4.0)
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.breed.name).font(.title).bold()
                    
                    HStack {
                        let temperamentCount = viewModel.breed.temperament.count
                        if temperamentCount == 0 {
                            EmptyView()
                        }
                        else if temperamentCount <= 3 {
                            ForEach(viewModel.breed.temperament, id: \.self) { tag in
                                BreedTemperamentView(temperament: tag)
                            }
                        }
                        else {
                            BreedTemperamentView(temperament: viewModel.breed.temperament[0])
                            BreedTemperamentView(temperament: viewModel.breed.temperament[1])
                            Spacer()
                            BreedTemperamentView(temperament: "+\(temperamentCount - 2)").fixedSize()
                        }
                    }
                }
                Spacer()
            }.padding()
        }
        
        
        //        ZStack {
        //            RoundedRectangle(cornerRadius: 13, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
        //                                                                                       startPoint: .topLeading,
        //                                                                                       endPoint: .bottomTrailing)).frame(height: 300)
        //
        //            VStack {
        //                HStack {
        //                    Spacer()
        //                    Image(systemName: viewModel.isFavourite ? "star.fill" : "star").onTapGesture {
        //                        let isFav = self.viewModel.isFavourite
        //                        print("Set \(self.viewModel.breed.name) to Favourite Status: \(!isFav)")
        //                        self.viewModel.isFavourite.toggle()
        //                    }.padding()
        //                }
        //                Spacer()
        //                ZStack {
        //                    Rectangle().fill(Color.black.opacity(0.6)).blur(radius: 54.37).cornerRadius(radius: 13, corners: [.bottomLeft, .bottomRight])
        //                    HStack {
        //                        VStack(alignment: .leading) {
        //                            Text(viewModel.breed.name).bold().foregroundColor(.white)
        //                            Text(viewModel.breed.description).foregroundColor(Color.white.opacity(0.75))
        //                        }
        //                    }.padding()
        //                }.frame(height: 100)
        //            }
        
        
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
