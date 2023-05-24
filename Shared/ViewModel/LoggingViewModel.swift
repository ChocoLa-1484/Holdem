//
//  LoggingViewModel.swift
//  Holdem (iOS)
//
//  Created by 楊乃諺 on 2023/5/24.
//

import SwiftUI

class LoggingViewModel: ObservableObject {
    
    func logging(account: String, password: String, completion: @escaping (Bool) -> Void) {
        // 构建查询条件
        let query = db.collection("player")
            .whereField("account", isEqualTo: account)
            .whereField("password", isEqualTo: password)

        // 执行查询
        query.getDocuments { (snapshot, error) in
            if let error = error {
                // 查询过程中出现错误
                print("Failed to get collection documents: \(error.localizedDescription)")
                completion(false)
            } else {
                guard let documents = snapshot?.documents else {
                    print("No documents found in the collection.")
                    completion(false)
                    return
                }
                
                if documents.isEmpty {
                    print("Account and password not found.")
                    completion(false)
                } else {
                    print("Account and password found.")
                    completion(true)
                }
            }
        }
    }
    
    func failResponse(on viewController: UIViewController) {
        let alertController = UIAlertController(title: "Fail", message: "Account or password incorrect.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 在视图控制器中弹出错误对话框
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func successResponse(on viewController: UIViewController) {
        let alertController = UIAlertController(title: "Success", message: "You successfully logged in!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
