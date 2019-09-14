//
//  IntroductionViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 6/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import ObjectMapper

class IntroductionViewController: UIViewController {
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        imageView.image = UIImage(named: "museum")?.image(alpha: 0.16)
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
        
        getData()
    }
    
    func getData() {
        let url = "http://104.199.252.182:9000/api/Beacon/introduction"
        AF.request(url, method: .get, parameters: ["id":1]).responseJSON { response in
            let model =  Mapper<IntroductionViewModel>().map(JSONObject: response.result.value)
            if let data = model {
                self.setupView(data: data)
            }else {
                //TODO: handle fail
            }
        }
    }

    func setupView(data : IntroductionViewModel) {
        introductionLabel.text = data.intro_desc
        descripLabel.text = data.intro_desc
        
        guard let url = URL(string: data.intro_img ?? "") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        imageView.image = UIImage(data: data)?.image(alpha: 0.16)
    }

    @IBAction func continueButtonClicked(_ sender: Any) {
        let home = HomeViewController()
        let vc = UINavigationController(rootViewController: home)
        self.present(vc, animated: true, completion: nil)

    }
}
