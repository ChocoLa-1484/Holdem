//
//  MainView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI

struct MainView: View {
    @StateObject private var mainViewModel = MainViewModel()
    var body: some View {
        Button {
            mainViewModel.test()
        } label: {
            Text("GOGO")
        }
        CardView(card: mainViewModel.playerCard)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
