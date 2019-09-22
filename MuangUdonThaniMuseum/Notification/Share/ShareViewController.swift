//
//  ShareViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 4/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import FBSDKShareKit

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel()
        titleLabel.text = "Share"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)//UIFont(name: "Roboto-Bold", size: 20)
        
        
        let hStack = UIStackView(arrangedSubviews: [titleLabel])
        hStack.spacing = 10
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        navigationController?.navigationBar.barTintColor = AppsColor.red
        navigationController?.navigationBar.isTranslucent = false
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        shareFB(sender: sender as AnyObject)
    }

    func shareFB(sender: AnyObject){
        //459273817999660
        let content = ShareLinkContent()
        content.contentURL =  URL(string: "https://goo.gl/maps/jWo2pw3PugPcP3Te9")!

        let dialog : ShareDialog = ShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = ShareDialog.Mode.native
        dialog.show()

    }

}
