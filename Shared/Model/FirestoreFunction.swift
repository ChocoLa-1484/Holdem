//
//  FirestoreFunction.swift
//  Holdem (iOS)
//
//  Created by User10 on BE 2566/5/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

let db = Firestore.firestore()

func searchId(collectionName: String) {
    db.collection(collectionName).getDocuments { (snapshot, error) in
        if let error = error {
            // 获取过程中出现错误
            print("Failed to get collection documents: \(error.localizedDescription)")
        } else {
            guard let documents = snapshot?.documents else {
                print("No documents found in the collection.")
                return
            }

            for document in documents {
                print("Collection ID: \(document.documentID)")
            }
        }
    }
}
