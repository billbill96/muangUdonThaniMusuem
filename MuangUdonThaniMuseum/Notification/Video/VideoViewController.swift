//
//  VideoViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 4/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import XCDYouTubeKit
import FBSDKShareKit

struct YouTubeVideoQuality {
    static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
    static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
    static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
}

class VideoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var firstTabBar: UITabBarItem!
    @IBOutlet weak var secondTabBar: UITabBarItem!
    @IBOutlet weak var thirdTabBar: UITabBarItem!
    
    
    let cellHeight: CGFloat = 275
    var videoUrl: [String] = []
    var videoDescrip: [String] = []
    var shareUrl: String = ""
    var navTitle = ""
    var facebook_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel()
        titleLabel.text = navTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)//UIFont(name: "Roboto-Bold", size: 20)
        
        
        let hStack = UIStackView(arrangedSubviews: [titleLabel])
        hStack.spacing = 10
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        navigationController?.navigationBar.barTintColor = AppsColor.red
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        tableView.register(UINib(nibName: "VideoCellTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = cellHeight

        tabBar.delegate = self
        firstTabBar.tag = 1
        secondTabBar.tag = 2
        thirdTabBar.tag = 3
        
        if shareUrl == "" {
            thirdTabBar.isEnabled = false
        }

        tabBar.selectedItem = secondTabBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBar.selectedItem = secondTabBar
    }
    
    convenience init() {
        self.init(title: "",video: [], videoDescrip: [], shareUrl: "", facebook_name: "")
    }
    
    init(title: String,video: [String], videoDescrip: [String],shareUrl: String,facebook_name: String) {
        var newVideoUrl: [String] = []
        var newDes: [String] = []
        for video in video {
            if video != "" {
                newVideoUrl.append(video)
            }
        }
        for des in videoDescrip {
            if des != "" {
                newDes.append(des)
            }
        }
        self.navTitle = title
        self.videoUrl = newVideoUrl
        self.videoDescrip = newDes
        self.shareUrl = shareUrl
        self.facebook_name = facebook_name
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VideoViewController: UITableViewDelegate, UITableViewDataSource,VideoCellTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoUrl.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VideoCellTableViewCell
        cell.setupCell(topic: videoDescrip[indexPath.row], urlVideo: videoUrl[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func playVideo(url: String) {
        var videoIdentifier = ""
        if let start = url.firstIndex(of: "=") {
            let index = url.index(after: start)
            let imgUrl = url[index..<url.endIndex]
            videoIdentifier = String(imgUrl)
        }
        
        let playerViewController = AVPlayerViewController()
        self.present(playerViewController, animated: true, completion: nil)
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                playerViewController?.player = AVPlayer(url: streamURL)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension VideoViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let homeVC = HomeViewController()
        let home = UINavigationController(rootViewController: homeVC)
        
        if item.tag == 1 {
            home.modalPresentationStyle = .fullScreen
            self.present(home,animated: true)
        }else if item.tag == 2{
//            setPresentViewController(viewController: videoVC)
        }else if item.tag == 3 {
            if shareUrl != "" {
                let content = ShareLinkContent()
                if let url =  URL(string: shareUrl.replacingOccurrences(of: " ", with: "")) {
                    content.contentURL =  url
                    let name = facebook_name.replacingOccurrences(of: "@", with: "").replacingOccurrences(of: " ", with: "")
                    content.hashtag = Hashtag("#\(name)")
                    
                    let dialog : ShareDialog = ShareDialog()
                    dialog.fromViewController = self
                    dialog.shareContent = content
                    dialog.delegate = self
                    let facebookURL = NSURL(string: "fbauth2://app")
                    if(UIApplication.shared.canOpenURL(facebookURL! as URL)){
                        dialog.mode = ShareDialog.Mode.native
                    }else{
                        dialog.mode = ShareDialog.Mode.feedWeb
                    }
                    dialog.show()
                } else {
                    let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension VideoViewController: SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("share complete")
        tabBar.selectedItem = secondTabBar
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("share fail")
        tabBar.selectedItem = secondTabBar
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("share cancel")
        tabBar.selectedItem = secondTabBar
    }
}
