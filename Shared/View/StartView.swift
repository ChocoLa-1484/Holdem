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
    @State var isShowingCreateRoomView: Bool = false
    @State var isShowingJoinRoomView: Bool = false
    @StateObject var loggingViewModel = LoggingViewModel()
    @StateObject var roomViewModel = RoomViewModel()
    @State var isLogged: Bool = false {
        didSet {
            if isLogged {
                // 执行登录成功后的操作
                UserManager.shared.loggedPlayer = loggingViewModel.loggedPlayer!
            } else {
                // 执行登出操作
                UserManager.shared.loggedPlayer = nil
            }
        }
    }
    
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
                    .frame(width: 300, height: 300, alignment: .topLeading)
                    .foregroundColor(Color.pink)
                    .overlay(
                        VStack{
                            Text(UserManager.shared.loggedPlayer?.name ?? "")
                            Text(UserManager.shared.loggedPlayer?.account ?? "")
                            Text(UserManager.shared.loggedPlayer?.password ?? "")
                            Text("\(UserManager.shared.loggedPlayer?.money ?? 0)")
                        }
                    )
                    .opacity(isLogged ? 1 : 0)
                    .offset(y: -200)
                VStack {
                    Button {
                        roomViewModel.createRoom(player: UserManager.shared.loggedPlayer!) {
                            isShowingCreateRoomView.toggle()
                        }
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
                .fullScreenCover(isPresented: $isShowingCreateRoomView) {
                    RoomView()
                }
                .fullScreenCover(isPresented: $isShowingJoinRoomView) {
                    JoinRoomView()
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
                LoggingView(isLogged: $isLogged)
                    .onDisappear {
                        isLogged = (loggingViewModel.loggedPlayer != nil)
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
