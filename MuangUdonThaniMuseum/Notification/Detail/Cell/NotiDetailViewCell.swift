//
//  NotiDetailTableViewCell.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 14/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Kingfisher

class NotiDetailViewCell: UITableViewCell {

    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        topicLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        topicLabel.textColor = AppsColor.grey
        descriptionTextView.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionTextView.textColor = AppsColor.lightGrey
    }
    
    func setupCell(img: String, topic: String, descrip: String) {
        topicLabel.text = topic
        descriptionTextView.text = descrip
        
        if let url = URL(string: img) {
            imageDetail.kf.setImage(with: url)
        }else {
            imageDetail.image = UIImage(named: "Unknown")
        }
    }

}
