//
//  UserManager.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/26.
//

import SwiftUI

class UserManager {
    static let shared = UserManager()
    
    var loggedPlayer: Player?
    
    private init() {}
}

