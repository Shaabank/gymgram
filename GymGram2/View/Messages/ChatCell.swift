//
//  ChatCell.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 30/03/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatCell: UICollectionViewCell {
    
    // MARK: Properties
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    var message: Message? {
        
        didSet{
            guard let messageText = message?.messageText else { return }
            textView.text = messageText
            
            guard let chatPartnerId = message?.getChatPartnerId() else { return }
            Database.fetchUser(with: chatPartnerId) { User in
                guard let profileImageUrl = User.profileImageUrl else { return }
                self.profileImageView.loadImage(with: profileImageUrl)
            }
            
        }
    }
    
    let bubbleView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
        view.translatesAutoresizingMaskIntoConstraints =  false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Sample text for now "
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        return tv
        
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds  = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: -4, paddingRight: 0, width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        
        // right anchor
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        // left anchor
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchor?.isActive = false
        
        // width and top anchor
        bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        // text View anchor
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
