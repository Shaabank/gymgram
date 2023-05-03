//
//  FollowVC.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 19/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase


private let reuseIdentifer = "FollowCell"

class FollowVC: UITableViewController, FollowTableViewCellDelegate {
    
    //MARK: - properties
    
    enum ViewingMode: Int {
        
        case Following
        case Followers
        case Likes
        
        init(index: Int) {
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    
    var postId: String?
    var viewingMode: ViewingMode!
    var uid: String?
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowTableViewCell.self, forCellReuseIdentifier: reuseIdentifer)
        
        // configure nav controller and fetch users
            
        // configure nav title
        configureNavigationTitle()
            
        // fetch users
            
        fetchUsers()
        //print("calling fetch user func")

        
        // clear the separator lines
        tableView.separatorColor = .clear
        
        //print("Viewing mode integer value is ", viewingMode.rawValue)
    }
    
    // MARK: -UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! FollowTableViewCell
        //cell.contentView.isUserInteractionEnabled = false
        cell.delegate = self
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let userProfileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    // MARK: FollowTableViewCellDelegate Protocol
    func handleFollowTapped(for cell: FollowTableViewCell) {
        guard let user = cell.user else { return }
        if user.isFollowed {
            user.unfollow()
            
            //configure follow button for non followed user
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
        } else {
            user.follow()
            
            // configure follow button for followed user
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
    }
    
    // MARK: Handlers
    func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }

        
        switch viewingMode {
        case .Followers: navigationItem.title = "Followers"
        case .Following: navigationItem.title = "Following"
        case .Likes: navigationItem.title = "Likes"
        }
    }
    
    // MARK: API
    
    func getDatabaseRefrence() -> DatabaseReference? {
        
        guard let viewingMode = self.viewingMode else { return nil }
        
        switch viewingMode {
        case .Followers: return USER_FOLLOWER_REF
        case .Following: return USER_FOLLOWING_REF
        case.Likes: return POST_LIKES_REF
        }
    }
    
    func fetchUser(with uid: String) {
        Database.fetchUser(with: uid, completion: { (User) in
            self.users.append(User)
            self.tableView.reloadData()
        })
    }
    
    func fetchUsers() {
        guard let ref = getDatabaseRefrence() else { return }
        guard let viewingMode = self.viewingMode else { return }
        
        switch viewingMode {
        case .Followers, .Following:
            guard let uid = self.uid else { return }

            ref.child(uid).observeSingleEvent(of: .value) { (DataSnapshot) in
                // here
                
                guard let allobjects = DataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allobjects.forEach({ DataSnapshot in
                    
                    let uid = DataSnapshot.key
                    
                    self.fetchUser(with: uid)
                })
                
            }
        case .Likes:
            
            guard let postId = self.postId else { return }
            ref.child(postId).observe(.childAdded, with: { (DataSnapshot) in
//                print("likes")
//               print(DataSnapshot)
                let uid = DataSnapshot.key
                self.fetchUser(with: uid)
            })
        }
    }
}
