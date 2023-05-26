//
//  JoinRoomView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var roomId: String = ""
    @StateObject private var roomViewModel = RoomViewModel()
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
            VStack {
                TextField("Room ID", text: $roomId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    roomViewModel.joinRoom(player: UserManager.shared.loggedPlayer!, roomId: roomId)
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
        .alert(isPresented: $roomViewModel.showAlert, content: {
            roomViewModel.alert
        })
        .fullScreenCover(isPresented: $roomViewModel.showRoom) {
            RoomView()
        }
    }
}

struct JoinRoomView_Previews: PreviewProvider {
    static var previews: some View {
        JoinRoomView()
    }
}
