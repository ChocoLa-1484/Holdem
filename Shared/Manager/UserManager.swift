//
//  UserManager.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserManager {
    static let shared = UserManager()
    
    private var loggedPlayer: Player? {
        didSet {
            updateIsLogged()
        }
    }
    
    private var isLoggedCallbacks: [(Bool) -> Void] = []
    
    private init() {}
    
    func setLoggedPlayer(_ player: Player) {
        loggedPlayer = player
    }
    
    func getLoggedPlayer() -> Player? {
        return loggedPlayer
    }
    
    func clearLoggedPlayer() {
        loggedPlayer = nil
    }
    
    func observeIsLogged(callback: @escaping (Bool) -> Void) {
        isLoggedCallbacks.append(callback)
        callback(loggedPlayer != nil)
    }
    
    private func updateIsLogged() {
        let isLogged = loggedPlayer != nil
        isLoggedCallbacks.forEach { $0(isLogged) }
    }
}


