//
//  PostTableViewCell.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 07/12/2022.
//
import AVFoundation
import SDWebImage
import UIKit
// cell for primary post content
// make it final so no one cant subclass it
final class PostTableViewCell: UITableViewCell {
    // add static to regiser the cell
    static let identifier = "PostTableViewCell"
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = nil
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.addSublayer(playerLayer)
        contentView.addSubview(postImageView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    public func configure(with post: UserPost) {
        postImageView.image = UIImage(named: "test")
        
        return
        switch post.postType {
        case .photo:
            // display image
            postImageView.sd_setImage(with: post.postURL, completed: nil)
        case .video:
            // display video
            player = AVPlayer(url: post.postURL)
            playerLayer.player = player
            playerLayer.player?.volume = 0
            playerLayer.player?.play()
            
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
        postImageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
}
