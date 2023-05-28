//
//  JoinRoomView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var roomID: String = ""
    @ObservedObject var roomViewModel: RoomViewModel
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                VStack {
                    TextField("Room ID", text: $roomID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button {
                        roomViewModel.joinRoom(roomID: roomID)
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
            .navigationBarItems(leading: backButton)
            .navigationViewStyle(StackNavigationViewStyle())
            .background(
                NavigationLink(destination: RoomView(roomViewModel: roomViewModel), isActive: $roomViewModel.showRoom) {
                    EmptyView()
                }
            )
            .alert(isPresented: $roomViewModel.showAlert, content: {
                roomViewModel.alert
            })
        }
    }
    
    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }
}
/*
struct JoinRoomView_Previews: PreviewProvider {
    static var previews: some View {
        JoinRoomView()
    }
}
*/
