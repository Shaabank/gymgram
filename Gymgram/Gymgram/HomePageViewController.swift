//
//  ViewController.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 11/11/2022.
//
// Import Firebase Authentication for Firebase Database

import FirebaseAuth
import UIKit

struct HomeFeedRenderViewModel {
    let header: PostRenderViewModel
    let post: PostRenderViewModel
    let actions: PostRenderViewModel
    let comments: PostRenderViewModel
}
class HomePageViewController: UIViewController {

    
    private var feedRebderModels = [HomeFeedRenderViewModel]()
    
    // create a table view for the home page
    private let tableView: UITableView = {
        let tableView = UITableView()
        //Register cells
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.register(PostHeaderTableViewCell.self, forCellReuseIdentifier: PostHeaderTableViewCell.identifier)
        tableView.register(PostActionsTableViewCell.self, forCellReuseIdentifier: PostActionsTableViewCell.identifier)
        tableView.register(PostComentsLikesTableViewCell.self, forCellReuseIdentifier: PostComentsLikesTableViewCell.identifier)
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createMockModels()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    
    private func createMockModels() {
        let user = User(username: "@Kamel",
                        bio: "",
                        name: (first: "", last: ""),
                        profilePhoto: URL(string: "https://www.google.com/")!,
                        birthDate: Date(),
                        gender: .male,
                        counts: UserCount(followers: 1, following: 1, posts: 1),
                        JoinedDate: Date())
        
        let post = UserPost(identifier: "",
                            postType: .photo,
                            thumbnailImage: URL(string: "https://www.google.com/")!,
                            postURL: URL(string: "https://www.google.com/")!,
                            caption: nil,
                            likeCount: [],
                            comments: [],
                            createdDate: Date(),
                            taggedUsers: [],
                            owner: user)
        var comments = [PostComment]()
        for x in 0..<2 {
            comments.append(PostComment(identifier: "\(x)", username: "@Merv", text: "This is the best post I've seen", createdDate: Date(), likes: []))
        }
        for x in 0..<5 {
            let viewModel = HomeFeedRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: user)),
                                                    post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                                                    actions: PostRenderViewModel(renderType: .actions(provider: "")),
                                                    comments: PostRenderViewModel(renderType: .comments(comments: comments)))
            feedRebderModels.append(viewModel)

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //call the userNotAuthenticated func
        userNotAuthenticated()
        
        //do {
            //try Auth.auth().signOut()
        //}
        //catch {
        //    print("Erorr")
        //}
        
            
        }
        
        private func userNotAuthenticated() {
            //Checking Authentication status of the user account if the user does not login, then the login page should display
            if Auth.auth().currentUser == nil {
                // here to diplay the login view controller if the user not authenticated
                let loginViewControl = LoginPageViewController()
                loginViewControl.modalPresentationStyle = .fullScreen
                present(loginViewControl, animated: false)
            
        }
    }


}

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    // number of sections in the table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedRebderModels.count * 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = section
        let model: HomeFeedRenderViewModel
        if x == 0 {
            model = feedRebderModels[0]
        }
        else {
            let position = x % 4 == 0 ? x/4 : ((x - (x % 4)) / 4)
            model = feedRebderModels[position]
        }
        
        let subSection = x % 4
        
        if subSection == 0 {
            //header
            return 1
        }
        
        if subSection == 1 {
            //post
            return 1
            
        }
        
        if subSection == 2 {
            //action
            return 1
        }
        
        if subSection == 3 {
            //comments
            let commentsModel = model.comments
            switch commentsModel.renderType {
            case .comments(let comments): return comments.count > 2 ? 2 : comments.count
            case .header, .actions, .primaryContent: return 0
            }
        }
        return 0
    }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let x = indexPath.section
            let model: HomeFeedRenderViewModel
            if x == 0 {
                model = feedRebderModels[0]
            }
            else {
                let position = x % 4 == 0 ? x/4 : ((x - (x % 4)) / 4)
                model = feedRebderModels[position]
            }
            
            let subSection = x % 4
            
            if subSection == 0 {
                //header
                
                switch model.header.renderType {
                case .header(let user):
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostHeaderTableViewCell.identifier, for: indexPath) as! PostHeaderTableViewCell
                    
                    cell.configure(with: user)
                    cell.delegate = self
                    return cell
                case .comments, .actions, .primaryContent: return UITableViewCell()
                }
                
            }
            
            if subSection == 1 {
                //post
                
                switch model.post.renderType {
                case .primaryContent(let post):
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
                    cell.configure(with: post)
                    return cell
                case .header, .actions, .comments: return UITableViewCell()
                }
                
                
            }
            
            if subSection == 2 {
                //action
                
                switch model.actions.renderType {
                case .actions(let provider):
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostActionsTableViewCell.identifier, for: indexPath) as! PostActionsTableViewCell
                    cell.delegate = self
                    return cell
                case .header, .primaryContent, .comments: return UITableViewCell()
                }
                
            }
            
            if subSection == 3 {
                //comments
                switch model.comments.renderType {
                case .comments(let comments):
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostComentsLikesTableViewCell.identifier, for: indexPath) as! PostComentsLikesTableViewCell
                    return cell
                case .header, .actions, .primaryContent: return UITableViewCell()
                }
                
            }
            return UITableViewCell()
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let subSection = indexPath.section % 4
            if subSection == 0 {
                // header section
                return 70
            }
            else if subSection == 1 {
                // Post section
                return tableView.width
            }
            
            else if subSection == 2 {
                // A tion section (like , Comments , Share )
                return 60
            }
            else if subSection == 3 {
                // Comment hieght for each row
                return 50
            }
            return 0
            
        }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let subSection = section % 4
        return subSection == 3 ? 70 : 0
    }
}

extension HomePageViewController: PostHeaderTableViewCellDelegate {
    func didTapMoreButton() {
        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { [weak self] _ in self?.reportPost()}))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    func reportPost() {
        
    }
}

extension HomePageViewController: PostActionsTableViewCellDelegate {
    func didTapLikeButton() {
        print("like")
    }
    
    func didTapCommentButton() {
        print("comment")
    }
    
    func didTapSendButton() {
        print("Send")
    }
}
