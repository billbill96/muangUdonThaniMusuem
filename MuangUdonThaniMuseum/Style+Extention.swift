//
//  Style.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 11/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import Foundation
import UIKit

enum AppsColor {
    static let oldRed = UIColor(rgb: 0x8D312A)
    static let red = UIColor(rgb: 0xCC2A2A)
    static let grey = UIColor(rgb: 0x505050)
    static let lightGrey = UIColor(rgb: 0x707070)
    static let darkGrey = UIColor(rgb: 0x4E4E4E)
    static let light = UIColor(rgb: 0xB61721)
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

public protocol ActivityIndicatorPresenter {

    /// The activity indicator
    var activityIndicator: UIActivityIndicatorView { get }

    /// Show the activity indicator in the view
    func showActivityIndicator()

    /// Hide the activity indicator in the view
    func hideActivityIndicator()
}

public extension ActivityIndicatorPresenter where Self: UIViewController {

    func showActivityIndicator() {
        DispatchQueue.main.async {

            self.activityIndicator.style = .whiteLarge
            self.activityIndicator.backgroundColor = UIColor(red: 0.16, green: 0.17, blue: 0.21, alpha: 0.5)
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80) //or whatever size you would like
            self.activityIndicator.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.height / 2)
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
}
