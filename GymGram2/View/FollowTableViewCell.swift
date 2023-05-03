//
//  FollowTableViewCell.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 19/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class FollowTableViewCell: UITableViewCell {
    
    // MARK: - properties
    
    var delegate: FollowTableViewCellDelegate?
    
    
    
    var user: User? {
        
        didSet {
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullName = user?.name else { return }
            //print("here is the user name\(username)")
            //print("here is the  name\(fullName)")
            profileImageView.loadImage(with: profileImageUrl)
            
            self.textLabel?.text = username
            
            self.detailTextLabel?.text = fullName
            
            
            // hide button for current user
            if user?.uid == Auth.auth().currentUser?.uid {
                followButton.isHidden = true
            }
            
            user?.checkIfUserIsFollowed(completion: { (followed) in
                if followed {
                    // configure follow button for followed user
                    self.followButton.configure(didFollow: true)
                    
                    
                } else {
                    // configure follow button for non followed user
                    self.followButton.configure(didFollow: false)
                }
            })
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Handlers
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        //display Follow button in Follow page
        addSubview(followButton)
        // teh style of the follow button and center it
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 3
        contentView.isUserInteractionEnabled = false
        
        textLabel?.text = "Username"
        
        detailTextLabel?.text = "Full Name"
        
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 108, height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        
        //textLabel?.text = "Username"
        
        //detailTextLabel?.text = "Full Name"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
