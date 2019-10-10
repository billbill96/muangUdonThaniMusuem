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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageTop: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var topic: String = ""
    var image: String = ""
    var detail: String = ""
    var navTitle: String = ""
    
    convenience init() {
        self.init(topic: "", image: "", detail: "",navTitle: "")
    }
    
    init(topic: String, image: String, detail: String, navTitle: String) {
        self.topic = topic
        self.image = image
        self.detail = detail
        self.navTitle = navTitle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel()
        titleLabel.text = navTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)//UIFont(name: "Roboto-Bold", size: 20)

        let hStack = UIStackView(arrangedSubviews: [titleLabel])
        navigationItem.titleView = hStack
        
        navigationController?.navigationBar.barTintColor = AppsColor.red
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2000)
        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
        
    func setupView() {
        topicLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        topicLabel.textColor = AppsColor.grey
        topicLabel.text = topic
        
        descriptionTextView.text = detail
        descriptionTextView.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionTextView.textColor = AppsColor.lightGrey
        
        if let url = URL(string: image.replacingOccurrences(of: " ", with: "%20")){
            imageTop.kf.setImage(with: url)
        } else {
            imageTop.image = UIImage(named: "Unknown")
        }
    }

    func setupStackView(images: [String]) {
//        for image in images {
//            let imageView = UIImageView()
//            imageView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
//            imageView.heightAnchor.constraint(equalToConstant: 250.0).isActive = true
//            guard let url = URL(string: image) else { return }
//            imageView.kf.setImage(with: url)
//            stackImage.addArrangedSubview(imageView)
//        }

    }
}

