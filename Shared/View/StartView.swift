//
//  StartView.swift
//  Holdem (iOS)
//
//  Created by User10 on BE 2566/5/24.
//

import SwiftUI

struct StartView: View {
    @State var isShowingRegisterView: Bool = false
    @State var isShowingLoggingView: Bool = false
    @State var isShowingJoinRoomView: Bool = false
    @ObservedObject var roomViewModel = RoomViewModel()
    @State var isLogged: Bool = false
    
    fileprivate func buttonLabel(text: String) -> some View {
        return Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
    }
    
    var body: some View {
        ZStack {
            ZStack{
                Rectangle()
                    .frame(width: 150, height: 150, alignment: .topLeading)
                    .foregroundColor(Color.pink)
                    .overlay(
                        VStack{
                            Text(UserManager.shared.loggedPlayer?.name ?? "")
                            Text("\(UserManager.shared.loggedPlayer?.money ?? 0)")
                        }
                    )
                    .opacity(isLogged ? 1 : 0)
                    .offset(x: -100, y: -100)
                VStack {
                    Button {
                        roomViewModel.createRoom(player: UserManager.shared.loggedPlayer!)
                    } label: {
                        buttonLabel(text: "Create Room")
                    }
                    .opacity(isLogged ? 1 : 0)
                    .disabled(!isLogged)
                    Button {
                        isShowingJoinRoomView.toggle()
                    } label: {
                        buttonLabel(text: "Join Room")
                    }
                    .opacity(isLogged ? 1 : 0)
                    .disabled(!isLogged)
                }
                .fullScreenCover(isPresented: $roomViewModel.showRoom) {
                    RoomView(roomViewModel: roomViewModel)
                }
                .fullScreenCover(isPresented: $isShowingJoinRoomView) {
                    JoinRoomView(roomViewModel: roomViewModel)
                }
            }
            VStack {
                Button {
                    isShowingRegisterView.toggle()
                } label: {
                    buttonLabel(text: "Sign Up")
                }
                .opacity(isLogged ? 0 : 1)
                .disabled(isLogged)
                Button {
                    isShowingLoggingView.toggle()
                } label: {
                    buttonLabel(text: "Sign In")
                }
                .opacity(isLogged ? 0 : 1)
                .disabled(isLogged)
            }
            .fullScreenCover(isPresented: $isShowingRegisterView) {
                RegisterView()
            }
            .fullScreenCover(isPresented: $isShowingLoggingView) {
                LoggingView()
                    .onDisappear {
                        isLogged = UserManager.shared.loggedPlayer != nil
                    }
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
