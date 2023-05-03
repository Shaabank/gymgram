//
//  PostViewController.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 18/01/2023.
//

import UIKit

/*
 section
 -Header Model
 section
 - Post cell Model
 - Action Buttons Cell Model
 - n number of general models for comments
 */

// atate of a render cell
enum PostRenderType {
    case header(provider: User)
    case primaryContent(provider: UserPost) //post
    case actions(provider: String) //Like , Comment, Share
    case comments(comments: [PostComment])
}
// Model of a render Post
struct PostRenderViewModel {
    let renderType: PostRenderType
}

class PostViewController: UIViewController {
    
    private let model: UserPost?
    
    private var renderModels = [PostRenderViewModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        
        //Register cells
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.register(PostHeaderTableViewCell.self, forCellReuseIdentifier: PostHeaderTableViewCell.identifier)
        tableView.register(PostActionsTableViewCell.self, forCellReuseIdentifier: PostActionsTableViewCell.identifier)
        tableView.register(PostComentsLikesTableViewCell.self, forCellReuseIdentifier: PostComentsLikesTableViewCell.identifier)
        
        
        
        
        return tableView
    }()
    
    // Mark: Init
    
    init(model: UserPost?) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        configureModls()
    }
    
    required init?(coder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureModls() {
        guard let userPostModel = self.model else {
            return
        }
        //header
        renderModels.append(PostRenderViewModel(renderType: .header(provider: userPostModel.owner)))
        //post
        renderModels.append(PostRenderViewModel(renderType: .primaryContent(provider: userPostModel)))

        //action
        renderModels.append(PostRenderViewModel(renderType: .actions(provider: "")))

        //comments
        var comments = [PostComment]()
        for x in 0..<4 {
            comments.append(PostComment(identifier: "123_\(x)", username: "@Kamal", text: "Great Post!", createdDate: Date(), likes: []))
            }
        renderModels.append(PostRenderViewModel(renderType: .comments(comments: comments)))

    }
   

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return renderModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch renderModels[section].renderType {
        case.actions(_): return 1
        case.comments(let comments): return comments.count > 4 ? 4 : comments.count
        case.primaryContent(_): return 1
        case.header(_): return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = renderModels[indexPath.section]
        
        switch model.renderType {
            case .actions(let actions):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostActionsTableViewCell.identifier, for: indexPath) as! PostActionsTableViewCell
                return cell
        case .comments(let comments):
            let cell = tableView.dequeueReusableCell(withIdentifier: PostComentsLikesTableViewCell.identifier, for: indexPath) as! PostComentsLikesTableViewCell
            return cell
            
        case .primaryContent(let post):
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
            return cell
            
        case .header(let user):
            let cell = tableView.dequeueReusableCell(withIdentifier: PostHeaderTableViewCell.identifier, for: indexPath) as! PostHeaderTableViewCell
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = renderModels[indexPath.section]
        
        switch model.renderType {
        case .actions(_): return 60
                
            
        case .comments(_): return 50

            
        case .primaryContent(_): return tableView.width
            
            
        case .header(_): return 70
         
        }
    }
}
