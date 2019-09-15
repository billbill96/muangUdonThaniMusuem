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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        topicLabel.font = UIFont(name: "HelveticaNeue-bold", size: 21)
        topicLabel.textColor = AppsColor.grey
        descripLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        descripLabel.textColor = AppsColor.lightGrey
    }
    
    func setupCell(img: String, topic: String, descrip: String) {
        topicLabel.text = topic
        descripLabel.text = descrip
        
        if let url = URL(string: img) {
            imageDetail.kf.setImage(with: url)
        }else {
            imageDetail.image = UIImage(named: "Unknown")
        }
    }

}
