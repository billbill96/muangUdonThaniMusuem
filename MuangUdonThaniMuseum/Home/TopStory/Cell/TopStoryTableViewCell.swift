//
//  TopStoryTableViewCell.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 7/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Kingfisher

class TopStoryTableViewCell: UITableViewCell {

    @IBOutlet weak var imageTopic: UIImageView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupCellView()
    }

    func setupCellView() {
        topicLabel.font = UIFont(name: "HelveticaNeue-Bold" , size: 21)
        topicLabel.textColor = AppsColor.grey
        timeLabel.font = UIFont(name: "HelveticaNeue", size: 10)
        timeLabel.textColor = AppsColor.grey
    }
    
    func setupCell(image: String, topic: String, time: String) {
        if let url = URL(string: image){
            imageTopic.kf.setImage(with: url)
        }
        else{
            imageTopic.image = UIImage(named: "Unknown")
        }
        
        topicLabel.text = topic
        timeLabel.text = time
    }
    
}
