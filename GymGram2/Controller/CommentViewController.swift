//
//  CommentViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 02/03/2023.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


private let reuseIdentifer = "CommentCell"

class CommentViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    var comments = [Comment]()
    var post: Post?
    
    lazy var containerView: CommentInputView = {
        //containerView.backgroundColor = .red
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let containerView = CommentInputView(frame: frame)
        
        containerView.backgroundColor = .white
        
        containerView.delegate = self
        
        return containerView
    }()
    
//    let commentTextField: UITextField = {
//        let tf = UITextField()
//        tf.placeholder = "Enter comment"
//        tf.font = UIFont.systemFont(ofSize: 14)
//        tf.backgroundColor = .clear
//        return tf
//    }()
    
//    let postButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Post", for: .normal)
//        button.setTitleColor(.blue, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//        button.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
//        return button
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure collection view
        // background color
        collectionView?.backgroundColor = .white
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        // Nav Title
        navigationItem.title = "Comments"
        
        // register cell class
        collectionView?.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifer)
        
        
        //fetch comments
        fetchComment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    // MARK: UIcollectionsView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCollectionViewCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! CommentCollectionViewCell
        
        handleHashtagTapped(forCell: cell)
        handleMentionTapped(forCell: cell)
        
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    // MARK: Handlers

    func handleHashtagTapped(forCell cell: CommentCollectionViewCell) {
        cell.commentLabel.handleHashtagTap { (hashtag) in
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag.lowercased()
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
    }
    
    func handleMentionTapped(forCell cell: CommentCollectionViewCell) {
        cell.commentLabel.handleMentionTap { username in
            self.getMentionUser(withUsername: username)
        }
    }
    
    // MARK: API
    
    func fetchComment() {
        
        guard let postId = self.post?.postId else { return }
        
        COMMENT_REF.child(postId).observe(.childAdded) { DataSnapshot in
        
            //print(DataSnapshot)
            
            guard let dictionary = DataSnapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(with: uid) { User in
                let comment = Comment(user: User, dictionary: dictionary)
                
                self.comments.append(comment)
                //print("user that commented is \(comment.user?.username)")
                self.collectionView?.reloadData()
                
                
            }
        }
    }
    
    
    func uploadCommentNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //guard let post = self.post else { return }
        guard let postId = self.post?.postId else { return }
        guard let uid = post?.user?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        
        // notification
        let values = ["checked": 0,
                     "creationDate": creationDate,
                     "uid": currentUid,
                     "type": COMMENT_INT_VALUE,
                     "postId": postId] as [String : Any]
        
        // upload comment  notification to server
        if uid != currentUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
        }
    }
}


extension CommentViewController: CommentInputViewDelegate {
    func didSubmit(forComment comment: String) {
        //print("handle upload comment")
        
        guard let postId = self.post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": comment, "creationDate": creationDate, "uid": uid] as [String : Any]
        
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            self.uploadCommentNotificationToServer()
            
            if comment.contains("@") {
                self.uploadMentionNotification(forPostId: postId, withText: comment, isForComment: false)
            }
            self.containerView.clearCommentTextView()
        }
    }
}
