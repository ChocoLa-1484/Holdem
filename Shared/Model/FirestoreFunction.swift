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

func searchDocument(collectionName: String, fieldName: String, target: String, completion: @escaping (String?) -> Void) {
   let collectionRef = Firestore.firestore().collection(collectionName)
   collectionRef.whereField(fieldName, isEqualTo: target).getDocuments { (snapshot, error) in
       if let error = error {
           print("Error searching documents: \(error)")
           completion(nil)
           return
       }

       guard let documents = snapshot?.documents else {
           print("No documents found")
           completion(nil)
           return
       }
       
       if let documentID = documents.first?.documentID {
           completion(documentID)
       } else {
           completion(nil)
       }
   }
}

func updateDocument(collectionName: String, target: String, fieldName: String, newValue: Any, completion: @escaping () -> Void) {
    let collectionRef = db.collection(collectionName)
    let documentRef = collectionRef.document(target)

    documentRef.updateData([fieldName: newValue]) { error in
       if let error = error {
           print("Error updating document: \(error)")
       } else {
           print("Document updated successfully")
           completion()
       }
   }
}
