//
//  GameView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/26.
//

import SwiftUI
import FirebaseFirestoreSwift

struct GameView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @Environment(\.presentationMode) var presentationMode
    @FirestoreQuery(collectionPath: "players", predicates: [
        .isEqualTo("roomID", UserManager.shared.getLoggedPlayer()!.roomID ?? "")
    ]) var players: [Player]
    @State private var isShowingRound = false
    
    var body: some View {
        NavigationView{
            VStack{
                /*
                VStack{
                    Text("\(UserManager.shared.getLoggedPlayer()!.roomID ?? "")")
                        .font(.title)
                        .bold()
                }*/
                HStack{
                    ForEach (players) { player in
                        gameBlock(player: player)
                    }
                }
            }
            .overlay(
                Text("Round \(gameViewModel.round)")
                    .frame(width: 80, alignment: .center)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .opacity(isShowingRound ? 1 : 0)
                    .animation(.easeInOut)
                    .transition(.opacity)
            )
            .navigationBarItems(leading: backButton)
            .onAppear(perform: {
                gameViewModel.startGame()
                //gameViewModel.gamelistenChange()
            })
            .onReceive(gameViewModel.$round) { newValue in
                isShowingRound = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    isShowingRound = false
                }
            }
        }
    }
    
    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            gameViewModel.exitGame()
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }
}
/*
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
*/
