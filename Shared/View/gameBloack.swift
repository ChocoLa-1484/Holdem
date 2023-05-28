//
//  gameBloack.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/28.
//

import SwiftUI

struct gameBlock: View {
    let player: Player
    var body: some View {
        VStack {
            VStack{
                Text(player.name)
                Text("$ \(player.money)")
            }
            VStack {
                ForEach (player.handCard ?? []) { card in
                    CardView(card: card)
                }
            }
        }
    }
}
/*
struct gameBloack_Previews: PreviewProvider {
    static var previews: some View {
        gameBloack()
    }
}
*/
