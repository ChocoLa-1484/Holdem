//
//  Player.swift
//  Holdem (iOS)
//
//  Created by User10 on BE 2566/5/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

struct Player: Codable, Identifiable {
    var id = UUID()
    
    let account: String
    var password: String
    
    var name: String
    var money: Int
    
    var handCard: [Card]?
    var bet: Int?
    
    func savePlayer(completion: @escaping () -> Void) {
        do {
            try db.collection("player").document().setData(from: self) { error in
                if let error = error {
                    print("Failed to store player data: \(error.localizedDescription)")
                } else {
                    print("Player data stored successfully")
                    completion()
                }
            }
        } catch {
            print("Failed to encode player data: \(error.localizedDescription)")
        }
    }

    func updatePlayer(newPassword: String? = nil, newName: String? = nil, newMoney: Int? = nil, completion: @escaping () -> Void) {
        var updatedData: [String: Any] = [:]
            
        // 检查并添加需要更新的属性到字典
        if let newPassword = newPassword {
            updatedData["password"] = newPassword
        }
        if let newName = newName {
            updatedData["name"] = newName
        }
        if let newMoney = newMoney {
            updatedData["money"] = newMoney
        }
        
        db.collection("player").document(self.account).updateData(updatedData) { error in
           if let error = error {
               print("Error updating player data: \(error.localizedDescription)")
           } else {
               completion() // 更新成功后执行完成处理程序
           }
       }
    }
    
}


