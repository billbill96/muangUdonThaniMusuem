//
//  NotiDescriptionViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 9/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Kingfisher

class TopStoryDescriptionViewController: UIViewController {

    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stackImage: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel()
        titleLabel.text = "Khun Thong Boran"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)//UIFont(name: "Roboto-Bold", size: 20)

        let hStack = UIStackView(arrangedSubviews: [titleLabel])
        navigationItem.titleView = hStack
        
        navigationController?.navigationBar.barTintColor = AppsColor.red
        navigationController?.navigationBar.tintColor = .white
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO: handle from noti show tabbar
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidLayoutSubviews() {
        descriptionLabel.sizeToFit()
    }
    
    func setupView() {
        topicLabel.font = UIFont(name: "HelveticaNeue-bold", size: 21)
        topicLabel.textColor = AppsColor.grey
        descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        descriptionLabel.textColor = AppsColor.lightGrey

        topicLabel.text = "Khun Thong Boran"
        descriptionLabel.text = "The sixth zone called Khun Thong Boran, A 3,000-Year-Old Ancestor Of Dogs showcases the skeleton of a dog unearthed in the compound of Wat Pho Sri Nai in Ban Chiang, Nong Han district, Udon Thani, between 2003-2004."
        
        setupStackView(images: ["https://f.ptcdn.info/528/058/000/pbl2puvqmiWhzv01YO4-o.jpg"])
    }

    func setupStackView(images: [String]) {
        for image in images {
            let imageView = UIImageView()
            imageView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 250.0).isActive = true
            guard let url = URL(string: image) else { return }
            imageView.kf.setImage(with: url)
            stackImage.addArrangedSubview(imageView)
        }
    }
}

