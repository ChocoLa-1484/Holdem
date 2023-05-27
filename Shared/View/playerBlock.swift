//
//  playerBlock.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/27.
//

import SwiftUI

struct playerBlock: View {
    let player: Player
    var body: some View {
        VStack {
            HStack{
                Text(player.name)
                Spacer()
                Text("\(player.money)")
            }
            VStack {
                ForEach (player.handCard!) { card in
                    CardView(card: card)
                }
            }
        }
    }
}
/*
struct playerBlock_Previews: PreviewProvider {
    static var previews: some View {
        playerBlock(player:)
    }
}
*/
