//
//  Authenticator.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 20/11/2022.
//

import Foundation
import FirebaseAuth

public class Authenticator {
    static let shared = Authenticator()
    
    public func registerNewUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        /*
         - check if username is available
         - check if email is available
         - create account
         - insert account to database
         */
        
        
        DatabaseManager.shared.canCreateNewUser(with: email, username: username) { canCreate in
            if canCreate {
                /*
                 - Create account
                 - insert account to database
                 */
                Auth.auth().createUser(withEmail: email, password : password) { result, error in
                    guard error == nil, result != nil else {
                        //firebase auth could not create account
                        completion(false)
                        return
                    }
                    
                    // insert into database
                    DatabaseManager.shared.insertNewUser(with: email, username: username) { inserted in
                        if inserted {
                            completion(false)
                            return
                            
                        }
                    }
                    
                    
                }
            }
            else {
                //either username or email does not exist
                completion(false)
            }
            
        }
        
    }
    
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // chech if the user log in with the email
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
        else if let username = username {
            // check user log in with the username
            print(username)
        }
    }
    
    //log out user
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch {
            print(error)
            completion(false)
            return
        }
    }
}
