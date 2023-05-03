//
//  models.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 18/01/2023.
//

import Foundation


enum Gender {
    case male, female, other
}

struct User {
    let username: String
    let bio: String
    let name: (first: String, last: String)
    let profilePhoto: URL
    let birthDate: Date
    let gender: Gender
    let counts: UserCount
    let JoinedDate: Date
}
struct UserCount {
    let followers: Int
    let following: Int
    let posts: Int
}
// enum just for photo and video
public enum UserPostType: String {
    case photo = "Photo"
    case video = "Video"
}
    //user post
public struct UserPost {
    let identifier: String
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL
    let caption: String?
    let likeCount: [PostLike]
    let comments: [PostComment]
    let createdDate: Date
    let taggedUsers: [String]
    let owner: User
}
//
struct PostLike {
    let username: String
    let postIdentifier: String
}
struct CommentLike {
    let username: String
    let commentIdentifier: String
    
}
struct PostComment {
    let identifier: String
    let username: String
    let text: String
    let createdDate: Date
    let likes: [CommentLike]
}

