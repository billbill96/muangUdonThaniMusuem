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
        
        guard let url = URL(string: urlVideo) else { return }
        if let thumbnailImage = getThumbnailImage(forUrl: url) {
            imageVideo.image = thumbnailImage
        }else {
            //TODO: default image
        }
        self.url = urlVideo
        imageVideo.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didClickImage))
        imageVideo.addGestureRecognizer(gesture)
        
    }
    
    @objc func didClickImage() {
        delegate.playVideo(url: url)
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
}
