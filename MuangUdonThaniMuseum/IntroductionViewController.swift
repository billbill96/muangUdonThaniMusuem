//
//  IntroductionViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 6/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Kingfisher

enum AppsColor {
    static let oldRed = UIColor(rgb: 0x8D312A)
    static let red = UIColor(rgb: 0xCC2A2A)
    static let grey = UIColor(rgb: 0x505050)
    static let lightGrey = UIColor(rgb: 0x707070)
    static let darkGrey = UIColor(rgb: 0x4E4E4E)
}

class IntroductionViewController: UIViewController {
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(named: "museum")?.image(alpha: 0.16)
        introductionLabel.textColor = AppsColor.oldRed
        descripLabel.textColor = AppsColor.oldRed
        descripLabel.lineBreakMode = .byWordWrapping
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(AppsColor.oldRed, for: .normal)
        continueButton.backgroundColor = .clear
        continueButton.layer.cornerRadius = 20
        continueButton.clipsToBounds = true
        continueButton.layer.borderColor = AppsColor.oldRed.cgColor
        continueButton.layer.borderWidth = 3
        
        setupView()
    }
    

    func setupView() {
        //TODO: get from api
        introductionLabel.text = "Introduction"
        descripLabel.text = "Udon Thani Museum locates on Pho Si road near Wat Pho. The building was built in 1920 by Phraya Sri Srisuriyacharavananuwat, officers, merchants, and people in the province. It was firstly used as a school building “Naree Foster School” completed in 1925. Later, King Rama VI. gave name of the school to Rachinuthit.Srisuriyacharavananuwat, officers, merchants, and people in the province. It was firstly used as a school building “Naree Foster School” completed in 1925. Later, King Rama VI. gave name of the school to Rachinuthit"
        
//        guard let url = URL(string: "https://f.ptcdn.info/528/058/000/pbl2puvqmiWhzv01YO4-o.jpg") else { return }
//        guard let data = try? Data(contentsOf: url) else { return }
//        imageView.image = UIImage(data: data)?.image(alpha: 0.16)
    }

    @IBAction func continueButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
        
//        let notiVC = NotiDescriptionViewController()
//        let noti = UINavigationController(rootViewController: notiVC)
//        self.present(noti, animated: true, completion: nil)
        
//        let homeVC = HomeViewController()
//        let home = UINavigationController(rootViewController: homeVC)
//        self.present(home, animated: true, completion: nil)
    }
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
