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
    @State private var isShowingRound = false
    @State private var isShowingStart = false
    var body: some View {
        NavigationView{
            VStack{
                VStack{
                    Text("\(UserManager.shared.getLoggedPlayer()!.roomID ?? "")")
                        .font(.title)
                        .bold()
                }
                HStack{
                    ForEach (gameViewModel.players) { player in
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
            .fullScreenCover(isPresented: $isShowingStart, content: {
                StartView()
            })
            .onAppear(perform: {
                gameViewModel.startGame()
                gameViewModel.gameListener()
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
            gameViewModel.exitGame()
            isShowingStart = true
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
