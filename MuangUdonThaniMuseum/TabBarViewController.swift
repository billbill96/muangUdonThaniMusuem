//
//  ViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 4/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let cellHeight: CGFloat = 319
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let homeVC = HomeViewController()
        let home = UINavigationController(rootViewController: homeVC)
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "icons8-home-filled-50"), selectedImage: UIImage(named: ""))
        
        let videoVC = VideoViewController()
        let video = UINavigationController(rootViewController: videoVC)
        videoVC.tabBarItem = UITabBarItem(title: "Video", image: UIImage(named: "icons8-facebook-26"), selectedImage: UIImage(named: ""))
        
        let shareVC = ShareViewController()
        let share = UINavigationController(rootViewController: shareVC)
        shareVC.tabBarItem = UITabBarItem(title: "Share", image: UIImage(named: "icons8-play-64"), selectedImage: UIImage(named: ""))
                
        self.viewControllers = [home,video,share]
    }


}
