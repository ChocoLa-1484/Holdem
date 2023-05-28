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
    @ObservedObject var loggingViewModel = LoggingViewModel()
    
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
            VStack {
                Button {
                    roomViewModel.createRoom()
                } label: {
                    buttonLabel(text: "Create Room")
                }
                .opacity(loggingViewModel.isLogged ? 1 : 0)
                .disabled(!loggingViewModel.isLogged)
                Button {
                    isShowingJoinRoomView.toggle()
                } label: {
                    buttonLabel(text: "Join Room")
                }
                .opacity(loggingViewModel.isLogged ? 1 : 0)
                .disabled(!loggingViewModel.isLogged)
            }
            .overlay(
                Rectangle()
                    .frame(width: 130, height: 130, alignment: .topLeading)
                    .foregroundColor(Color.pink)
                    .overlay(
                        VStack{
                            Text(UserManager.shared.getLoggedPlayer()?.name ?? "")
                            Text("\(UserManager.shared.getLoggedPlayer()?.money ?? 0)")
                            Button {
                                loggingViewModel.logout()
                            } label: {
                                buttonLabel(text: "Log out")
                            }
                        }
                    )
                .opacity(loggingViewModel.isLogged ? 1 : 0)
                .offset(x: -200, y: -100)
            )
            .fullScreenCover(isPresented: $roomViewModel.showRoom) {
                RoomView(roomViewModel: roomViewModel)
            }
            .fullScreenCover(isPresented: $isShowingJoinRoomView) {
                JoinRoomView(roomViewModel: roomViewModel)
            }
            VStack {
                Button {
                    isShowingRegisterView.toggle()
                } label: {
                    buttonLabel(text: "Sign Up")
                }
                .opacity(loggingViewModel.isLogged ? 0 : 1)
                .disabled(loggingViewModel.isLogged)
                Button {
                    isShowingLoggingView.toggle()
                } label: {
                    buttonLabel(text: "Sign In")
                }
                .opacity(loggingViewModel.isLogged ? 0 : 1)
                .disabled(loggingViewModel.isLogged)
            }
            .fullScreenCover(isPresented: $isShowingRegisterView) {
                RegisterView()
            }
            .fullScreenCover(isPresented: $isShowingLoggingView) {
                LoggingView(loggingViewModel: loggingViewModel)
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
