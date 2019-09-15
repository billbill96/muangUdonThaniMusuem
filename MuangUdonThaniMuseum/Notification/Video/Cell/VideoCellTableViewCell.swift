//
//  VideoCellTableViewCell.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 9/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoCellTableViewCellDelegate {
    func playVideo(url : String)
}

class VideoCellTableViewCell: UITableViewCell {

    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var imageVideo: UIImageView!
    
    var url: String = ""
    var delegate: VideoCellTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(topic: String, descrip: String, urlVideo: String) {
        topicLabel.font = UIFont(name: "HelveticaNeue-medium", size: 25)
        descripLabel.font = UIFont(name: "HelveticaNeue-regular", size: 16)
        topicLabel.textColor = AppsColor.darkGrey
        descripLabel.textColor = AppsColor.darkGrey
        topicLabel.text = topic
        descripLabel.text = descrip
        
        let imgStr = getThumbnailImage(url: urlVideo)
        if let url = URL(string: imgStr) {
            imageVideo.kf.setImage(with: url)
        }else {
            imageVideo.image = UIImage(named: "Unknown")
        }
        
        self.url = urlVideo
        imageVideo.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didClickImage))
        imageVideo.addGestureRecognizer(gesture)
        
    }
    
    @objc func didClickImage() {
        delegate.playVideo(url: url)
    }
    
    func getThumbnailImage(url: String) -> String {
        if let start = url.firstIndex(of: "=") {
            let index = url.index(after: start)
            let imgUrl = url[index..<url.endIndex]
            let url = "https://img.youtube.com/vi/\(imgUrl)/mqdefault.jpg"
            return String(url)
        }
        return ""
    }
    
}
