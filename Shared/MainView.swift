//
//  MainView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/23.
//

import SwiftUI

struct MainView: View {
    @StateObject private var gameViewModel = GameViewModel()
        
        var body: some View {
            VStack {
                HStack {
                    CardView(card: gameViewModel.playerCard, title: "玩家")
                    CardView(card: gameViewModel.computerCard, title: "電腦")
                }
                Text("玩家金額：\(gameViewModel.playerMoney)")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    gameViewModel.drawCards()
                }) {
                    Text("抽牌比大小")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $gameViewModel.showAlert) {
                    Alert(title: Text(gameViewModel.alertTitle), message: nil, dismissButton: .default(Text("確定")))
                }
            }
            .padding()
        }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
