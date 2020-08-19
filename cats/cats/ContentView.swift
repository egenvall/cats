//
//  ContentView.swift
//  cats
//
//  Created by Kim Egenvall on 2020-08-19.
//  Copyright © 2020 Kim Egenvall. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = BreedOverviewViewModel()
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            if viewModel.breeds.isEmpty {
                EmptyView()
            }
            else {
                ForEach(viewModel.breeds, content: BreedItemView.init(viewModel:))
            }
        }.onAppear(perform: {
            print("Fetching Breeds")
            self.viewModel.fetchBreeds()
        })
        
    }
}


struct BreedItemView: View {
    let viewModel: BreedViewModel
    var body: some View {
        Text(viewModel.breed.id)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
