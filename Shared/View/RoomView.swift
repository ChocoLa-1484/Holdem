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
    @State var showAlert: Bool = false
    @State var alert = Alert(title: Text("HI"))
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
            .fullScreenCover(isPresented: $roomViewModel.showGameView, content: {
                GameView()
            })
            .alert(isPresented: $showAlert) {
                if roomViewModel.showNotReady {
                    return roomViewModel.alert
                } else {
                    return alert
                }
            }
            .onReceive(roomViewModel.$showNotReady) { showNotReady in
                showAlert = showAlert || showNotReady
            }
            .onChange(of: players) { updatedPlayers in
                if updatedPlayers.isEmpty {
                    alert = Alert(
                        title: Text("Empty Room"),
                        message: Text("Host left"),
                        dismissButton: .default(Text("OK")) {
                            showAlert = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    )
                    showAlert = true
                }
            }
            .onAppear(perform: {
                roomViewModel.roomListener()
            })
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
