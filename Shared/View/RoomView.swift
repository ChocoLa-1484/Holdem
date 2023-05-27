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
        ZStack(alignment: .topLeading) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "x.circle")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            }
            HStack{
                Text("\(roomViewModel.roomId)")
                    .font(.title)
                    .bold()
                Spacer()
                Spacer()
            }
            VStack{
                ForEach (roomViewModel.players) { player in
                    playerBlock(player: player)
                }
            }
        }
        .onAppear(perform: {
            print(roomViewModel.players)
            print(roomViewModel.roomId)
        })
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView()
    }
}
