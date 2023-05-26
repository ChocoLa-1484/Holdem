//
//  RoomView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI
import GameKit

struct RoomView: View {
    @StateObject private var roomViewModel = RoomViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack{
            ForEach (roomViewModel.players) { player in
                Text(player.name)
            }
        }
        .onAppear(perform: {
            
        })
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView()
    }
}
