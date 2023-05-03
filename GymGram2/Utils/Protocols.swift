//
//  Protocols.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 18/02/2023.
//

import Foundation


protocol UserProfileHeaderCollectionViewCellDelegate {
    
    func handleEditFollowTapped(for header: UserProfileHeaderCollectionViewCell)
    func setUserStats(for header: UserProfileHeaderCollectionViewCell)
    func handleFollowersTapped(for header: UserProfileHeaderCollectionViewCell)
    func handleFollowingTapped(for header: UserProfileHeaderCollectionViewCell)
}

protocol FollowTableViewCellDelegate {
    func handleFollowTapped(for cell: FollowTableViewCell)
}


protocol FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol HomeCellDelegate {
    func handleUsernameTapped(for cell: HomeCollectionViewCell)
    func handleOptionsTapped(for cell: HomeCollectionViewCell)
    func handleLikeTapped(for cell: HomeCollectionViewCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: HomeCollectionViewCell)
    func handleConfigureLikeButton(for cell: HomeCollectionViewCell)
    func handleShowLikes(for cell: HomeCollectionViewCell)
    func configureCommentIndicatorView(for cell: HomeCollectionViewCell)
    
}

protocol NotificationCellDelegate {
    func handleFollowTapped(for cell: NotificationTableViewCell)
    func handlePostTapped(for cell: NotificationTableViewCell)
}

protocol Printable {
    var description: String { get }
}


protocol CommentInputViewDelegate {
    func didSubmit(forComment comment: String)
}

//

protocol MessageInputAccesoryViewDelegate {
    func handleUploadMessage(message: String)
    func handleSelectImage()
}

protocol ChatCellDelegate {
    func handlePlayVideo(for cell: ChatCell)
}

protocol MessageCellDelegate {
    func configureUserData(for cell: MessagesTableViewCell)
}
