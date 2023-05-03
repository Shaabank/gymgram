//
//  Extensions.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 15/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIButton {
    func configure(didFollow: Bool) {
        if didFollow {
            //handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
            
        } else {
            
            
            //handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}

extension Date {
    
    func timeAgoToDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "SECOND"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "MIN"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "HOUR"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "DAY"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "WEEK"
        } else {
            quotient = secondsAgo / month
            unit = "MONTH"
        }
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "S") AGO"
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
 
}

extension UIViewController {
    
    func getMentionUser(withUsername username: String) {
        USER_REF.observe(.childAdded) { DataSnapshot in
            //print(DataSnapshot)
            let uid = DataSnapshot.key
            
            USER_REF.child(uid).observeSingleEvent(of: .value) { DataSnapshot in
                //print(DataSnapshot)
                
                guard let dictionary = DataSnapshot.value as? Dictionary<String, AnyObject> else { return }
                
                if username == dictionary["username"] as? String {
                    Database.fetchUser(with: uid) { User in
                        let userProfileController = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
                        userProfileController.user = User
                        self.navigationController?.pushViewController(userProfileController, animated: true)
                        return
                    }
                }
            }
        }
    }
    
    func uploadMentionNotification(forPostId postId: String, withText text: String, isForComment: Bool) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        var mentionIntegerValue: Int!
        
        if isForComment {
            mentionIntegerValue = COMMENT_MENTION_INT_VALUE
        } else {
            mentionIntegerValue = POST_MENTION_INT_VALUE
        }
        
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: .symbols)
                word = word.trimmingCharacters(in: .punctuationCharacters)
                
                USER_REF.observe(.childAdded) { DataSnapshot in
                    let uid = DataSnapshot.key
                    
                    USER_REF.child(uid).observeSingleEvent(of: .value) { DataSnapshot in
                        guard let dictionary = DataSnapshot.value as? Dictionary<String, AnyObject> else { return }
                        
                        if word == dictionary["username"] as? String {
                            let notificationValues = ["postId": postId, "uid": currentUid, "type": COMMENT_MENTION_INT_VALUE, "creationDate": creationDate] as [String: Any]
                            
                            if currentUid != uid {
                                NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(notificationValues)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Database {
    static func  fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        USER_REF.child(uid).observeSingleEvent(of: .value) { DataSnapshot in
            guard let dictionary = DataSnapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { DataSnapshot in
            
            guard let dictionary = DataSnapshot.value as? Dictionary<String, AnyObject> else { return }
            
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid) { User in
                let post = Post(postId: postId, user: User, dictionary: dictionary)
                
                completion(post)
            }
            
        }
    }
}

extension String {
    func isValidPassword() -> Bool {
        var isValid = true
        let size = self.count
        let regex = try! Regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,15}$")

        if self.wholeMatch(of: regex) == nil{
            isValid = false
        }


        return isValid
    }

    func isValidEmail() -> Bool{
        var isValid = true
        let regex = try! Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,64}")
        if self.wholeMatch(of: regex) == nil {
            print("invalid")
            isValid = false
        }


        return isValid
    }

    func isValidFullName() -> Bool {
        var isValid = true
        let regex = try! Regex("[A-Za-z]{1,25} [A-Za-z]{1,25}")
        if self.wholeMatch(of: regex) == nil {
            isValid = false
        }

        return isValid
    }

    func isValidUserName() -> Bool {
        var isValid = true
        let regex = try! Regex("[A-Za-z0-9]{6,20}")
        
        if self.wholeMatch(of: regex) == nil {
            isValid = false
        }

        return isValid
    }
}
