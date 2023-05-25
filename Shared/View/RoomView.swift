//
//  CreateRoomView.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

struct RoomView: View {
    @StateObject private var roomViewModel = RoomViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView()
    }
}
