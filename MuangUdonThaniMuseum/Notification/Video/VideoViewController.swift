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

class VideoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)

    let cellHeight: CGFloat = 275
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView()
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 17),
            imageView.widthAnchor.constraint(equalToConstant: 17)
            ])
        imageView.image = UIImage(named: "icons8-home-filled-50-white")
        
        let titleLabel = UILabel()
        titleLabel.text = "Video"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)//UIFont(name: "Roboto-Bold", size: 20)
        
        
        let hStack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        hStack.spacing = 10
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        navigationController?.navigationBar.barTintColor = AppsColor.red
        
        tableView.register(UINib(nibName: "VideoCellTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = cellHeight

        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.yellow
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }

}

extension VideoViewController: UITableViewDelegate, UITableViewDataSource,VideoCellTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VideoCellTableViewCell
        cell.setupCell(topic: "Example 1", descrip: "sample caption asdfasdfalksdjfaklscasdasdkjfaklsjdfklajsdklfjaklsjcklajsklcmasdfmaksjdfklasdlkfjaskldfjkalsdjfklajsdklfjaskldfjaklsdcas", urlVideo: "https://www.youtube.com/watch?v=Izz0bHVOF_8")
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func playVideo(url: String) {
        guard let url = URL(string: url) else { return }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
