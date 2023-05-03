//
//  Post.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 21/02/2023.
//

import FirebaseCore
import Foundation
import FirebaseAuth
import FirebaseStorage

class Post {
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false
    
    init(postId: String!, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        
        guard let  currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        if addLike {
            
            
            
            // update user-likes in database
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in
                
                // send notification to server
                self.senddLikeNotificationToServer()
                
                //update Post-likes database
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1], withCompletionBlock: { (err, ref) in
                    
                    self.likes = self.likes + 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                    //print("Successfully upload like structures in database")
                    //print("number of likes is \(self.likes)")

                })
            })

            
        } else {
            
            // observe database for notifi id ti be remove
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { DataSnapshot in
                
                // notification id to remove from server
                guard let notificationID = DataSnapshot.value as? String else { return }
                
                // remove notifi from server
                NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue { (err, ref) in
                    //remove Like from user-like database
                    USER_LIKES_REF.child(currentUid).child(postId).removeValue(completionBlock: { (err, ref) in
                        //remove Like from post-like database
                        POST_LIKES_REF.child(self.postId).child(currentUid).removeValue(completionBlock: { (err, ref) in
                            guard self.likes > 0 else { return }
                            self.likes = self.likes - 1
                            self.didLike = false
                            completion(self.likes)

                            //print("This post has \(likes) likes")
                            
                            POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                            //print("Successfully remove likes from database")
                            //print("number of likess is \(self.likes)")

                        })
                    })
                }
            }
        }
    }
    
    func deletePost() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
        }
        
        USER_FEED_REF.child(currentUid).child(postId).removeValue()
        
        USER_POSTS_REF.child(currentUid).child(postId).removeValue()
        
        POST_LIKES_REF.child(postId).observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let notificationId = snapshot.value as? String else { return }
                
                NOTIFICATIONS_REF.child(self.ownerUid).child(notificationId).removeValue(completionBlock: { (err, ref) in
                    
                    POST_LIKES_REF.child(self.postId).removeValue()
                    
                    USER_LIKES_REF.child(uid).child(self.postId).removeValue()
                })
            })
        }
        
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                HASHTAG_POST_REF.child(word).child(postId).removeValue()
            }
        }
        
        COMMENT_REF.child(postId).removeValue()
        POSTS_REF.child(postId).removeValue()
    }
    
    func senddLikeNotificationToServer() {
        
        //properties
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //guard let postId = post.postId else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // send notification if like is for post that not current user
        if currentUid != self.ownerUid {
            
            // notification
            let values = ["checked": 0,
                         "creationDate": creationDate,
                         "uid": currentUid,
                         "type": LIKE_INT_VALUE,
                         "postId": postId] as [String : Any]
            
            // notification data ref store it
            let notifiactionRef = NOTIFICATIONS_REF.child(self.ownerUid).childByAutoId()
            
            // upload notification to database
            
            notifiactionRef.updateChildValues(values, withCompletionBlock: { err, ref in
                USER_LIKES_REF.child(currentUid).child(self.postId).setValue(notifiactionRef.key)
            })
        }
    }
}


