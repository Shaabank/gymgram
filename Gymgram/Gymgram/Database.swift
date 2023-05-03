//
//  Database.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 20/11/2022.
//

import Foundation
import FirebaseDatabase
//let ref = Database.database(url: "https://apps.europe-west1.firebasedatabase.app")

public class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    /*
     - check if the username and email is available
     - parameters
     -- email: String representing email
     -- username : String representing username
     */
    public func canCreateNewUser(with email: String, username: String, completion: (Bool) -> Void) {
        completion(true)
        
    }
    
    /*
     - insert new user data to database
     - parameters
     -- email: String representing email
     -- username : String representing username
     -- completion : Async callback for result if database entry succeeded
     */
    
    public func insertNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        let key = email.safeDatabaseKey()
        database.child(key).setValue(["username": username]) {error, _ in
            if error == nil {
                // succeeded
                completion(true)
                return
            }
            else {
                // failed
                completion(false)
                return
            }
        }
        
    }
    

    
}
