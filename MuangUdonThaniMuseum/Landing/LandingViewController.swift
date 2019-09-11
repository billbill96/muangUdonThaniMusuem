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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLabel.textColor = AppsColor.oldRed
        getData()
    }
    

    func getData() {
        let url = "http://104.199.252.182:9000/api/Beacon/welcome"
        AF.request(url, method: .get).responseJSON { response in
            let model =  Mapper<LandingViewModel>().mapArray(JSONObject: response.result.value)
            if let data = model?[0] {
                print(data)
                self.setupView(data: data)
            }else {
                //TODO: handle fail
            }
        }
    }

    func setupView(data: LandingViewModel) {
        welcomeLabel.text = data.intro_desc
        
        guard let url = URL(string: data.start_img!) else { return }
        backgroundImage.kf.setImage(with: url)
//        changeViewController()
    }
    
    func changeViewController() {
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "IntroductionViewController") as? IntroductionViewController else { return }
            self.present(vc,animated: true, completion: nil)

        }

    }
}
