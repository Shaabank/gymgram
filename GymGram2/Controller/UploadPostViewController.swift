//
//  UploadPostViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 17/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class UploadPostViewController: UIViewController, UITextViewDelegate {
    
    
    
    
    // MARK: - properties
    enum UploadAction: Int {
        case UploadPost
        case SaveChanges
        
        init(index: Int) {
            switch index {
            case 0: self = .UploadPost
            case 1: self = .SaveChanges
            default: self = .UploadPost
            }
        }
    }
    
     
    var uploadAction: UploadAction!
    var selectedImage: UIImage?
    var postToEdit: Post?
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let captionTextView: UITextView = {
        let txv = UITextView()
        txv.backgroundColor = UIColor.groupTableViewBackground
        txv.font = UIFont.systemFont(ofSize: 12)
        return txv
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
        return button
    }()
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        //configure view components
        configureViewComponents()
        
        
        
        //load image func
        loadImage()
        
        // text view delegate
        captionTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureViewController(forUploadAction: uploadAction)
        
//        if uploadAction == .SaveChanges {
//
//            guard let post = self.postToEdit else { return }
//            actionButton.setTitle("Save Changes", for: .normal)
//            self.navigationItem.title = "Edit Post"
//            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
//            navigationController?.navigationBar.tintColor = .black
//            photoImageView.loadImage(with: post.imageUrl)
//            captionTextView.text = post.caption
//
//        } else {
//
//            actionButton.setTitle("Share", for: .normal)
//            self.navigationItem.title = "Upload Post"
//
//
//        }
        

    }
    
    // MARK: - UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        //print(textView.text)
        
        guard !textView.text.isEmpty else {
            
            actionButton.isEnabled = false
            actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        actionButton.isEnabled = true
        actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 273/255, alpha: 1)
        
    }
    
    // MARK: - Handlers
    
    @objc func handleUploadAction() {
        buttonSelector(uploadAction: uploadAction)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
        case .UploadPost:
            handleUploadPost()
        case .SaveChanges:
            handleSavePostChanges()
            
        }
    }
    
    func configureViewController(forUploadAction uploadAction: UploadAction) {
        if uploadAction == .SaveChanges {
            guard let post = self.postToEdit else { return }
            actionButton.setTitle("Save Changes", for: .normal)
            self.navigationItem.title = "Edit Post"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationController?.navigationBar.tintColor = .black
            photoImageView.loadImage(with: post.imageUrl)
            captionTextView.text = post.caption
        } else {
            actionButton.setTitle("Share", for: .normal)
            self.navigationItem.title = "Upload Post"
        }
    }
        
    func loadImage() {
        
        guard let selectedImage = self.selectedImage else { return }
        
        photoImageView.image = selectedImage
    }
    
    func configureViewComponents() {
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
            
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
            
        view.addSubview(actionButton)
        actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    }
    
    // MARK: API
    
//    func updateUserFeeds(with postId: String) {
//
//        // current user id
//
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//
//        // database values
//        let values = [postId: 1]
//
//        // update follower home
//        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { DataSnapshot in
//            let followerUid = DataSnapshot.key
//            USER_FEED_REF.child(followerUid).updateChildValues(values)
//        }
//
//        //update current user
//        USER_FEED_REF.child(currentUid).updateChildValues(values)
//    }

    
    func handleSavePostChanges() {
        
        guard let post = self.postToEdit else { return }
        guard let updatedCaption = captionTextView.text else { return }

        
        if updatedCaption.contains("#") {
            self.uploadHashtagToServer(withPostId: post.postId)
        }
//        let updateCaption = captionTextView.text
//        uploadHashtahToServer(withPosyId: post.postId)
        
        POSTS_REF.child(post.postId).child("caption").setValue(updatedCaption) { (err, ref) in
            self.dismiss(animated: true, completion:  nil)
        }
    }
    
    
    
    func handleUploadPost() {
        //print("handle share post working")
        
        // parameters
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //print("Post caption is \(caption)")
        
        // image uploda data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
        
        
        //creating date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // update storage
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        storageRef.putData(uploadData, metadata: nil) { metadata, error in
            
            //handle error
            if let error = error {
                print("Failed to upload imafe to storage with error", error.localizedDescription)
                return
            }
            
            // image url
            storageRef.downloadURL(completion: { (url, error) in
                guard let imageUrl = url?.absoluteString else { return }
                
                //post data
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": imageUrl,
                              "ownerUid": currentUid] as [String: Any]
                
                // post ID
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
                
                // upload info to database
                postId.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    // update user post structure
                    let userPostsRef = USER_POSTS_REF.child(currentUid)
                    userPostsRef.updateChildValues([postKey: 1])
                    
                    // update user-home in database
                    
                    self.updateUserFeeds(with: postKey)
                    
                    // upload hashtag to server
                    if caption.contains("#") {
                        self.uploadHashtagToServer(withPostId: postKey)
                    }
                    
                    // upload mention notification to server
                    if caption.contains("@") {
                        self.uploadMentionNotification(forPostId: postKey, withText: caption, isForComment: true)
                    }
                    
                    // return to home page
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                })
            })
        }
    }
    
    func updateUserFeeds(with postId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let values = [postId: 1]
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
        
  
    func uploadHashtagToServer(withPostId postId: String) {
        guard let caption = captionTextView.text else { return }
        
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }
        
        
}

