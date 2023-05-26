//
//  GameView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/26.
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel = GameViewModel()
    var body: some View {
        Button {
            gameViewModel.test()
        } label: {
            Text("GOGO")
        }
        CardView(card: gameViewModel.playerCard)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
