//
//  RoomView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI
import GameKit
import FirebaseFirestoreSwift

struct RoomView: View {
    @ObservedObject var roomViewModel: RoomViewModel
    @Environment(\.presentationMode) var presentationMode
    @FirestoreQuery(collectionPath: "players", predicates: [
        .isEqualTo("roomID", UserManager.shared.getLoggedPlayer()!.roomID ?? "")
    ]) var players: [Player]
    @State private var showAlert: Bool = false
    var body: some View {
        NavigationView{
            VStack{
                VStack{
                    Text("\(UserManager.shared.getLoggedPlayer()!.roomID ?? "")")
                        .font(.title)
                        .bold()
                }
                HStack{
                    ForEach (players) { player in
                        playerBlock(player: player)
                    }
                }
                readyButton
            }
            .navigationBarItems(leading: backButton, trailing: startButton)
            .navigationViewStyle(StackNavigationViewStyle())
            .background(
                NavigationLink(destination: GameView(), isActive: $roomViewModel.showGameView) {
                    EmptyView()
                }
            )
            .alert(isPresented: $roomViewModel.showNotReady, content: {
                roomViewModel.alert
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Empty Room"),
                    message: Text("Host left"),
                    dismissButton: .default(Text("OK")) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .onAppear(perform: {
                roomViewModel.roomListener()
            })
            .onChange(of: players) { updatedPlayers in
                if updatedPlayers.isEmpty {
                    showAlert = true
                }
            }
        }
    }
    
    private var backButton: some View {
        Button(action: {
            self.roomViewModel.exitRoom()
            roomViewModel.showGameView = false
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }
    
    private var startButton: some View {
        Button(action: {
            self.roomViewModel.startGame()
        }) {
            Text("Start")
                .font(.title)
                .bold()
        }
        .disabled(!UserManager.shared.getLoggedPlayer()!.host)
        .opacity(UserManager.shared.getLoggedPlayer()!.host ? 1 : 0)
    }
    
    private var readyButton: some View {
        Button(action: {
            self.roomViewModel.getReady()
        }) {
            Text("Get Ready")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
        }
    }
}
/*
struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView()
    }
}
*/
