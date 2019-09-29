//
//  LandingViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 6/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher

class LandingViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLabel.textColor = AppsColor.oldRed
        getData()
    }
    

    func getData() {
        let url = "http://104.199.252.182:9000/api/Beacon/welcome"
        AF.request(url, method: .get, parameters: ["id":1]).responseJSON { response in
            let model =  Mapper<LandingViewModel>().map(JSONObject: response.value)
            if let data = model {
                self.setupView(data: data)
            }else {
                
            }
        }
    }

    func setupView(data: LandingViewModel) {
        welcomeLabel.text = data.start_desc
        
        guard let url = URL(string: data.start_img!) else { return }
        backgroundImage.kf.setImage(with: url)
        backgroundHeight.constant = view.frame.height / 2
        changeViewController()
    }
    
    func changeViewController() {
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "IntroductionViewController") as? IntroductionViewController else { return }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc,animated: true, completion: nil)
        }
    }
}
