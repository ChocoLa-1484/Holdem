//
//  HoldemApp.swift
//  Shared
//
//  Created by 楊乃諺 on 2023/5/23.
//
import SwiftUI
import Foundation
import Firebase

@main
struct HoldemApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
