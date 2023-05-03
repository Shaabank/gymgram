//
//  HomaPageCollectionViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 17/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import ActiveLabel

private let reuseIdentifier = "Cell"

class HomaPageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomeCellDelegate {
    
    
    
    
    // MARK: * properties
    
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var currentKey: String?
    var userProfileController: ProfileCollectionViewController?
    
    
    
    var messageNotificationView: MessageNotificationView = {
        let view = MessageNotificationView()
        return view
    }()
    
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        
        // Register cell classes
        self.collectionView!.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure refresh control
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        // Logout button
        configureNavigationBar()
        
        // fetch APi posts
        if !viewSinglePost {
            fetchPosts()
        }
        
        //updateUserFeed()
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUnreadMessageCount()
    }
    
    // MARK: UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        
        return CGSize(width: width, height: height)
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewSinglePost {
            return 1
        }else {
            return posts.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
        
        cell.delegate = self
        
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
            
        } else {
            cell.post = posts[indexPath.row]
        }
        
        handleHashtagTapped(forCell: cell)
        
        handleUsernameLableTapped(forCell: cell)
        
        handleMentionTapped(forCell: cell)
        // Configure the cell
        
        return cell
    }
    // MARK: Home Delegate   (protocol)
    
    func handleUsernameTapped(for cell: HomeCollectionViewCell) {
        //print("Handle user name tapped")
        
        guard let post = cell.post else { return }
        let userProfileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = post.user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cell: HomeCollectionViewCell) {
        guard let post = cell.post else { return }
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
                post.deletePost()
                
                if !self.viewSinglePost {
                    self.handleRefresh()
                } else {
                    if let userProfileController = self.userProfileController {
                        _ = self.navigationController?.popViewController(animated: true)
                        userProfileController.handleRefresh()
                    }
                    
                }

            }))
            
            alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { (_) in
                //print("edit post")
                let uploadPostController = UploadPostViewController()
                let navigationController = UINavigationController(rootViewController: uploadPostController)
                uploadPostController.postToEdit = post
                uploadPostController.uploadAction = UploadPostViewController.UploadAction(index: 1)
                self.present(navigationController, animated: true, completion: nil)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // To handle Likes in the post
    
    func handleLikeTapped(for cell: HomeCollectionViewCell, isDoubleTap: Bool) {
        //print("Handle likes tapped")
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        if post.didLike {
            //handle unlike post
            if !isDoubleTap {
                post.adjustLikes(addLike: false, completion: { (likes) in
                    //print("number of likes is \(likes)")
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                })
            }
            // updateLikesStructures(with: postId, addLike: false)
        } else {
            //handle like post
            post.adjustLikes(addLike: true, completion: { (likes) in
                cell.likesLabel.text = "\(likes) likes"
                
                //print("number of likes is \(likes)")
                
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                //updateLikesStructures(with: postId, addLike: true)
                
            })
        }
    }
    
    func handleShowLikes(for cell: HomeCollectionViewCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        //print("Handle show likes here")
        
        let followLikeVC = FollowVC()
        followLikeVC.viewingMode = FollowVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleConfigureLikeButton(for cell: HomeCollectionViewCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { DataSnapshot in
            //print(DataSnapshot)
            
            if DataSnapshot.hasChild(postId) {
                
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                
                //print("User has liked post")
            } else {
                //print("User has not liked post")
                post.didLike = false
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
            }
            
        }
    }
    
    func configureCommentIndicatorView(for cell: HomeCollectionViewCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        COMMENT_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let ks = cell.stackView {
                    
                    cell.addCommentIndicatorView(toStackView: ks)
                }
            } else {
                cell.commentIndicatorView.isHidden = true
            }
        }
    }
    
    
    
    func handleCommentTapped(for cell: HomeCollectionViewCell) {
        //print("Handle comments tapped")
        guard let post = cell.post else { return }
        let commentVC = CommentViewController(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
        
    }
    
    // MARK: handlers
    
    @objc func handleRefresh() {
        //print("refresh done")
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    @objc func handleShowMessages() {
        let messagesController = MessagesVC()
        self.messageNotificationView.isHidden = true
        navigationController?.pushViewController(messagesController, animated: true)
    }
    
    func handleHashtagTapped(forCell cell: HomeCollectionViewCell) {
        cell.captionLabel.handleHashtagTap { hashtag in
            //print("Hashtag is \(hashtag)")
            
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
    }
    func handleMentionTapped(forCell cell: HomeCollectionViewCell) {
        cell.captionLabel.handleMentionTap { username in
            self.getMentionUser(withUsername: username)
        }
    }
    
    func handleUsernameLableTapped(forCell cell: HomeCollectionViewCell) {
        guard let user = cell.post?.user else { return }
        
        guard let username = cell.post?.user?.username else { return }
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        cell.captionLabel.handleCustomTap(for: customType) { _ in
            
            let userProfileController = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        }
    }
    
    
    func configureNavigationBar() {
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2") , style: .plain, target: self, action: #selector(handleShowMessages))
            
        }
        
        
        
        self.navigationItem.title = "Home"
    }
    
    func setUnreadMessageCount() {
        if !viewSinglePost {
            getUnreadMessageCount { (unreadMessageCount) in
                guard unreadMessageCount != 0 else { return }
                self.navigationController?.navigationBar.addSubview(self.messageNotificationView)
                self.messageNotificationView.anchor(top: self.navigationController?.navigationBar.topAnchor, left: nil, bottom: nil, right: self.navigationController?.navigationBar.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 20, height: 20)
                self.messageNotificationView.layer.cornerRadius = 20 / 2
                self.messageNotificationView.notificationLabel.text = "\(unreadMessageCount)"
            }
        }
    }
    
    
    @objc func handleLogout() {
        
        // declare alert C
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //add alert logout action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                
                // attempt sign in
                try Auth.auth().signOut()
                
                // display login C
                let loginVC = LoginViewController()
                
                let navController = UINavigationController(rootViewController: loginVC)
                
                navController.modalPresentationStyle = .fullScreen
                
                self.present(navController,animated: true, completion: nil)
                print("Successfuly logged out ....")
            } catch {
                
                // handle error
                print("faild to sign out...!")
            }
        }))
        // cancel alert
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: API
    func updateUserFeed() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { DataSnapshot in
            //print(DataSnapshot)
            
            let followingUserId = DataSnapshot.key
            
            USER_POSTS_REF.child(followingUserId).observe(.childAdded) { DataSnapshot in
                //print(DataSnapshot)
                let postId = DataSnapshot.key
                
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            }
        }
        
        USER_POSTS_REF.child(currentUid).observe(.childAdded) { DataSnapshot in
            let postId = DataSnapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            
        }
    }
    func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
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
            USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with: { (snapshot) in
                
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
        Database.fetchPost(with: postId) { Post in
            self.posts.append(Post)
            self.posts.sort { Post1, Post2 -> Bool in
                return Post1.creationDate > Post2.creationDate
            }
            self.collectionView?.reloadData()
        }
    }
    
    
    func getUnreadMessageCount(withCompletion completion: @escaping(Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let unreadCount = 0
        
        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                
                MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
                    guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                    
                    _ = Message(dictionary: dictionary)
                    
//                    if message.fromId != currentUid {
//                        if !message.read  {
//                            unreadCount += 1
//                        }
//                    }
                    completion(unreadCount)
                }
            })
        }
    }
}
