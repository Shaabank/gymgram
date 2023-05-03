//
//  HashtagController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 11/04/2023.
//

import UIKit
import FirebaseDatabase


private let reuseIdentifier = "HashtagCell"

class HashtagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: properites
    
    var posts = [Post]()
    var hashtag: String?
    
    //MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HashtagCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        fetchPosts()
    }
    
    // MARK: UICollectionViewFlowLayout
    
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
    
    // MARK: UIcollectionView

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCollectionViewCell
        
        cell.post = posts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let homeVC = HomaPageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        homeVC.viewSinglePost = true
        homeVC.post = posts[indexPath.row]
        
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
    // MARK: Handlers
    func configureNavigationBar() {
        guard let hashtag = self.hashtag else { return }
        navigationItem.title = hashtag
    }
    
    // MARK: API
    
    func fetchPosts() {
        guard let hashtag = self.hashtag else { return }
        HASHTAG_POST_REF.child(hashtag).observe(.childAdded) { DataSnapshot in
            let postId = DataSnapshot.key
            
            Database.fetchPost(with: postId) { Post in
                self.posts.append(Post)
                self.collectionView?.reloadData()
            }
        }
    }

    
    
}
