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
        HStack {
            VStack{
                Text(player.name)
                Text("$ \(player.money)")
                readyText
            }
        }
    }
    private var readyText: some View {
        Text("Ready")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(player.ready ? Color.blue : Color.gray)
            .cornerRadius(10)
    }
}
/*
struct playerBlock_Previews: PreviewProvider {
    static var previews: some View {
        playerBlock(player:)
    }
}
*/
