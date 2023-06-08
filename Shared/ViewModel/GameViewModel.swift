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
    @Published var players: [Player] = []
    var room: Room = Room(roomStatus: "waiting", players: [])
    var roomID: String = ""
    var waiting: Bool = false
    
    func startGame() {
        print("Start Game")
        self.roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        round += 1
        
        let roomRef = db.collection("rooms").document(roomID)
        roomRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, let room = try? snapshot.data(as: Room.self) else { return }
            self.room = room
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.dealTwoRoundsToPlayers() { success in
                    if success {
                        print("initialing game is finished")
                    } else {
                        print("initialing game is failed")
                    }
                }
            }
        }
    }
    func dealCardToPlayer(playerID: String, completion: @escaping (Bool) -> Void) {
        // 获取指定房间的文档引用
        let roomRef = db.collection("rooms").document(self.roomID)
        
        roomRef.getDocument { (snapshot, error) in
            guard let snapshot = snapshot, snapshot.exists, var room = try? snapshot.data(as: Room.self) else {
                print("failed to deal one card")
                completion(false)
                return
            }
            
            // 从room.deck发一张牌给指定playerID
            guard let card = room.deck?.cards.removeFirst() else {
                print("deck is empty")
                completion(false)
                return
            }
            
            // 更新player的handCard字段
            let playerRef = db.collection("players").document(playerID)
            playerRef.getDocument { snapshot, error in
                guard let snapshot = snapshot, snapshot.exists, var player = try? snapshot.data(as: Player.self) else {
                    print("failed to get player")
                    return
                }
                if player.handCard == nil {
                    player.handCard = []
                }
                player.handCard?.append(card)
                try? playerRef.setData(from: player) { error in
                    if error != nil {
                        print("failed to update player")
                        completion(false)
                    } else {
                        // 从room.deck.cards中移除发出的牌
                        // 更新房间的deck字段
                        try? roomRef.setData(from: room) { error in
                            if error != nil {
                                print("failed to update room")
                                completion(false)
                            } else {
                                print("deal \(card.rank) \(card.suit) to \(playerID) successfully")
                                print("successed to update room")
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func dealOneRound(completion: @escaping (Bool) -> Void) {
        // 获取指定房间的文档引用
        let roomRef = db.collection("rooms").document(self.roomID)
        
        roomRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, let room = try? snapshot.data(as: Room.self) else {
                print("failed to deal one round")
                completion(false)
                return
            }
            let dispatchGroup = DispatchGroup()
            for playerID in room.players {
                dispatchGroup.enter()
                self.dealCardToPlayer(playerID: playerID) { success in
                    if success {
                        print("successed to deal card to \(playerID)")
                    } else {
                        print("failed to deal card to \(playerID)")
                        completion(false)
                        return
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                print("successed to deal one round")
                completion(true)
            }
        }
    }
    func dealTwoRoundsToPlayers(completion: @escaping (Bool) -> Void) {
        self.dealOneRound() { success in
            if success {
                self.dealOneRound() { success in
                    completion(success)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func exitGame() {
        var player = UserManager.shared.getLoggedPlayer()!
        let roomID = UserManager.shared.getLoggedPlayer()?.roomID ?? ""
        player.roomID = nil
        player.host = false
        player.handCard = nil
        deletePlayerFromGame(playerID: UserManager.shared.getLoggedPlayer()?.id ?? "", roomID: roomID)
        modifyPlayer()
    }
    
    func modifyPlayer() {
        let player = UserManager.shared.getLoggedPlayer()!
        try? db.collection("players").document(player.id ?? "").setData(from: player)
    }
    func gameListener() {
        db.collection("players").whereField("roomID", isEqualTo: self.roomID).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    guard let player = try? documentChange.document.data(as: Player.self) else { return }
                    self.players.append(player) // 将新增的玩家添加到players数组中
                case .modified:
                    guard let player = try? documentChange.document.data(as: Player.self),
                          let index = self.players.firstIndex(where: { $0.id == player.id }) else {
                        return
                    }
                    self.players[index] = player // 更新已修改的玩家数据
                    
                case .removed:
                    guard let player = try? documentChange.document.data(as: Player.self),
                          let index = self.players.firstIndex(where: { $0.id == player.id }) else {
                        return
                    }
                    self.players.remove(at: index) // 从players数组中删除已删除的玩家
                }
            }
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
                roomRef.getDocument { snapshot, error in
                   guard let snapshot = snapshot, snapshot.exists, let room = try? snapshot.data(as: Room.self) else {
                       print("Room document does not exist")
                       return
                   }
                    if room.players.isEmpty {
                       // 刪除房間
                       roomRef.delete { error in
                           if let error = error {
                               print("Error deleting room: \(error)")
                           } else {
                               print("Room deleted successfully")
                           }
                       }
                   }
                }
            }
        }
        // 刪除players collection下的roomID
        db.collection("players").document(playerID).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else { return }
            
            let playerRef = snapshot.reference
            playerRef.updateData(["roomID": FieldValue.delete()]) { error in
                if let error = error {
                    print("Error updating roomID: \(error)")
                } else {
                    print("roomID set to nil successfully")
                }
            }
        }
    }
}
