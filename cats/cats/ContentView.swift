import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = BreedOverviewViewModel()
    var body: some View {
        NavigationView {
            GeometryReader { g in
                List(self.viewModel.breeds, id: \.id) { breed in
                    BreedItemView(viewModel: breed)
            }.edgesIgnoringSafeArea([.bottom, .horizontal]).navigationBarTitle("Main").onAppear(perform: {
            print("Fetching Breeds")
            self.viewModel.fetchBreeds()
            })
            }
        }
    }
}




struct BreedItemView: View {
    @ObservedObject var viewModel: BreedViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                                                                       startPoint: .topLeading,
                                                                                       endPoint: .bottomTrailing)).frame(height: 300)
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: viewModel.isFavourite ? "star.fill" : "star").onTapGesture {
                        let isFav = self.viewModel.isFavourite
                        print("Set \(self.viewModel.breed.name) to Favourite Status: \(!isFav)")
                        self.viewModel.isFavourite.toggle()
                    }.padding()
                }
                Spacer()
                ZStack {
                    Rectangle().fill(Color.black.opacity(0.6)).blur(radius: 54.37).cornerRadius(radius: 13, corners: [.bottomLeft, .bottomRight])
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.breed.name).bold().foregroundColor(.white)
                            Text(viewModel.breed.description).foregroundColor(Color.white.opacity(0.75))
                        }
                    }.padding()
                }.frame(height: 100)
            }
            
            
        }
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
