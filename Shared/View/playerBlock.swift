//
//  playerBlock.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/27.
//

import SwiftUI

struct playerBlock: View {
    let player: Player
    @ObservedObject var roomViewModel: RoomViewModel
    var body: some View {
        VStack {
            VStack{
                Text(player.name)
                Text("$ \(player.money)")
                readyButton
            }
        }
    }
    private var readyButton: some View {
        Button(action: {
            self.roomViewModel.getReady()
        }) {
            Text("Ready")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(player.ready)
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
