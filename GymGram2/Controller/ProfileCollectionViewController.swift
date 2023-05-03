 //
//  ProfileCollectionViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 17/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class ProfileCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderCollectionViewCellDelegate {
    
    // MARK: - properties
    
    var user: User?
    var posts = [Post]()
    var currentKey: String?
    
    // MARK: INit
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UserPostCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        configureRefreshControl()
        
        // background Color
        self.collectionView?.backgroundColor = .white
        
        
        //fetch user data
        if self.user == nil {
            fetchCurrentUserData()
        }
        
        // fetch post
        fetchPosts()
    }
    
    
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    
    
    
    // MARK: - UICollectionV
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 9 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeaderCollectionViewCell
        
        // set delegate
        header.delegate = self
        
        // set the user in header
        header.user = self.user
        navigationItem.title = user?.username
      
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCollectionViewCell
        
        cell.post = posts[indexPath.item]
    
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let homeVC = HomaPageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        homeVC.viewSinglePost = true
        homeVC.userProfileController = self
        homeVC.post = posts[indexPath.item]
        
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
    // MARK: - user profile header protocol
    
    func handleFollowersTapped(for header: UserProfileHeaderCollectionViewCell) {
        let followVC = FollowVC()
        followVC.viewingMode = FollowVC.ViewingMode(index: 1)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeaderCollectionViewCell) {
        let followVC = FollowVC()
        followVC.viewingMode = FollowVC.ViewingMode(index: 0)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    func handleEditFollowTapped(for header: UserProfileHeaderCollectionViewCell) {
        guard let user = header.user else { return }

        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            let editProfileController = EditProfileController()
            editProfileController.user = user
            editProfileController.userProfileController = self
            let navigationController = UINavigationController(rootViewController: editProfileController)
            present(navigationController, animated: true, completion: nil)
        } else {

            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    func setUserStats(for header: UserProfileHeaderCollectionViewCell) {
        
        guard let uid = header.user?.uid else { return }
        
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        
        // get number of followers
        USER_FOLLOWER_REF.child(uid).observe(.value) { DataSnapshot in
            if let DataSnapshot = DataSnapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = DataSnapshot.count
            } else {
                numberOfFollowers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "Followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }

        
        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { (DataSnapshot)  in
            
            if let DataSnapshot = DataSnapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = DataSnapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "Following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
        }
        
        // get number of posts
        USER_POSTS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            let postCount = snapshot.count
            
            let attributedText = NSMutableAttributedString(string: "\(postCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.postLabel.attributedText = attributedText
        }
    }
    
    // MARK: Handlers
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }

    
    // MARK: - API
    
    func fetchPosts() {
        var uid: String!
        
        if let user = self.user {
            uid = user.uid
        }
        else {
            uid = Auth.auth().currentUser?.uid
        }
        
        // initial data pull
        if currentKey == nil {
            
            USER_POSTS_REF.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.collectionView?.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                })
                self.currentKey = first.key
            })
        } else {
            
            USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                })
                self.currentKey = first.key
            })
        }
        
    }
    
    func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { (post) in
            
            self.posts.append(post)
            
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            })
            self.collectionView?.reloadData()
        }
    }
    
    
    func fetchCurrentUserData() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("authResult").child(currentUid).observeSingleEvent(of: .value) { DataSnapshot in
            guard let dictionary = DataSnapshot.value as? Dictionary<String, AnyObject> else { return }
            let uid = DataSnapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.navigationItem.title = user.username
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView?.reloadData()
        }
    }
}
