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
            VStack {
                Button {
                    isShowingCreateRoomView.toggle()
                } label: {
                    buttonLabel(text: "Create Room!")
                }
                .opacity(isLogged ? 1 : 0)
                .disabled(!isLogged)
                Button {
                    isShowingJoinRoomView.toggle()
                } label: {
                    buttonLabel(text: "Join Room!")
                }
                .opacity(isLogged ? 1 : 0)
                .disabled(!isLogged)
            }
            .fullScreenCover(isPresented: $isShowingCreateRoomView) {
                CreateRoomView(presentationMode: $isShowingCreateRoomView)
            }
            .fullScreenCover(isPresented: $isShowingJoinRoomView) {
                JoinRoomView(presentationMode: $isShowingJoinRoomView)
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
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
