//
//  PostComentsLikesTableViewCell.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 09/12/2022.
//

import UIKit

class PostComentsLikesTableViewCell: UITableViewCell {

    static let identifier = "PostComentsLikesTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemOrange
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func configure() {
        // configure cell
        
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
