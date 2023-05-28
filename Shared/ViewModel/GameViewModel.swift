//
//  GameViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/26.
//

import Foundation
import FirebaseFirestore

class GameViewModel: ObservableObject {
    @Published var round: Int = 0
    var room: Room?
    func startGame() {
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let documentRef = db.collection("rooms").document(roomID)
        round += 1
        documentRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching room document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let roomData = snapshot.data() else {
                print("Room document data is nil")
                return
            }
            // 解析房间数据为 Room 对象，你需要根据你的数据模型进行调整
            if let room = try? Firestore.Decoder().decode(Room.self, from: roomData) {
                self.room = room
            }
        }
//        self.dealCardsToPlayers(index: 0, count: 0, target: 2)
    }
    
    func dealCardsToPlayers(index: Int, count: Int, target: Int) {
        guard index < self.room!.players.count else {
            // 所有玩家都已发牌，开始下一阶段
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.waitForPlayerToPlay(index: 0)
            }
            return
        }
        
        let playerID = room!.players[index]
        
        if count < target {
            // 发一张牌给当前玩家
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dealOneCard(playerID: playerID)
                self.dealCardsToPlayers(index: index, count: count + 1, target: target)
            }
        } else {
            // 发牌给下一个玩家
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dealCardsToPlayers(index: index + 1, count: 0, target: target)
            }
        }
    }
    
    func waitForPlayerToPlay(index: Int) {
        guard index < room!.players.count else {
            // 所有玩家都已出牌，继续下一阶段
            startNextPhase()
            return
        }
        
        // let playerID = room!.players[index]
        // 等待玩家出牌逻辑
        
        // 出牌完成后，等待下一个玩家出牌
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.waitForPlayerToPlay(index: index + 1)
        }
    }

    func startNextPhase() {
        dealCardsToPlayers(index: 0, count: 0, target: 1)
    }
    
    func gamelistenChange() {
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let documentRef = db.collection("rooms").document(roomID)
        documentRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching room document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let roomData = snapshot.data() else {
                print("Room document data is nil")
                return
            }
            // 解析房间数据为 Room 对象，你需要根据你的数据模型进行调整
            if let room = try? Firestore.Decoder().decode(Room.self, from: roomData) {
                print("Room:", room)
                
                // 根据德州扑克的游戏逻辑进行相应的处理
                // 判断游戏是否开始
                // 根据德州扑克的游戏规则进行相应的操作
                // 包括发牌、下注、判断牌型、决定胜负等
                
                // 例如，发牌给每个玩家
                for playerID in room.players {
                    self.dealOneCard(playerID: playerID)
                    // 根据游戏规则发牌给玩家
                }
                
                // 其他游戏逻辑的处理...
                
            }  else {
                print("Failed to decode room data")
            }
        }
    }
    func dealOneCard(playerID: String) {
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        let documentRef = db.collection("rooms").document(roomID)
        documentRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                print("Room document does not exist")
                return
            }
            
            guard var roomData = snapshot.data() else {
                print("Room document data is nil")
                return
            }
            
            if var deck = roomData["deck"] as? [Card] {
                guard !deck.isEmpty else {
                    // 重新洗牌
                    return
                }
                // 移除第一张牌
                self.addHandCard(playerID: playerID, card: deck.first!)
                deck.removeFirst()
                
                // 更新牌堆数据到文档
                roomData["deck"] = deck
                documentRef.updateData(roomData) { error in
                    if let error = error {
                        print("Error updating deck: \(error.localizedDescription)")
                    } else {
                        print("Deck updated successfully")
                    }
                }
            } else {
                print("Invalid deck data type")
            }
        }
    }
    
    func addHandCard(playerID: String, card: Card){
        let playerRef = db.collection("players").document(playerID)
        playerRef.getDocument { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching player document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            guard let playerData = snapshot.data() else {
                print("Player document data is nil")
                return
            }
            
            if (playerData["handCard"] as? [Card]) != nil {
                playerRef.updateData(["handCard": FieldValue.arrayUnion([card])])
            } else {
                playerRef.setData(["handCard": card])
            }
        }
    }
    func exitGame() {
        var player = UserManager.shared.getLoggedPlayer()!
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        player.roomID = nil
        player.host = false
        
        deletePlayerFromGame(playerID: UserManager.shared.getLoggedPlayer()?.id ?? "", roomID: roomID)
        modifyPlayer()
    }
    
    func modifyPlayer() {
        let player = UserManager.shared.getLoggedPlayer()!
        do {
            try db.collection("players").document(player.id ?? "").setData(from: player)
        } catch  {
            print(error)
        }
    }
    
    func deletePlayerFromGame(playerID: String, roomID: String) {
        let roomRef = db.collection("rooms").document(roomID)
        // 刪除rooms collection下players
        roomRef.updateData([
            "players": FieldValue.arrayRemove([playerID])
        ]) { error in
            if let error = error {
                print("Error deleting player from room: \(error)")
            } else {
                print("Player deleted from room successfully")
            }
        }
        // 刪除players collection下的roomID
        db.collection("players").document(playerID).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                let playerRef = snapshot.reference
                playerRef.updateData(["roomID": FieldValue.delete()]) { error in
                    if let error = error {
                        print("Error updating roomID: \(error)")
                    } else {
                        print("roomID set to nil successfully")
                    }
                }
            } else {
                print("Player document does not exist")
            }
        }
    }
}
