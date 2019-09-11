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
