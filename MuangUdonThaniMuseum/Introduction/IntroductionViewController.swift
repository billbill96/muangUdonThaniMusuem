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
import PromiseKit

class IntroductionViewController: UIViewController,ActivityIndicatorPresenter {
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var activityIndicator = UIActivityIndicatorView()


    override func viewDidLoad() {
        super.viewDidLoad()

//        imageView.image = UIImage(named: "museum")?.image(alpha: 0.16)
        introductionLabel.textColor = AppsColor.oldRed
        introductionLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        
        descripLabel.textColor = AppsColor.oldRed
        descripLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descripLabel.lineBreakMode = .byWordWrapping
        descripLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(AppsColor.oldRed, for: .normal)
        continueButton.backgroundColor = .clear
        continueButton.layer.cornerRadius = 20
        continueButton.clipsToBounds = true
        continueButton.layer.borderColor = AppsColor.oldRed.cgColor
        continueButton.layer.borderWidth = 3
        
        continueButton.isHidden = true
        showActivityIndicator()
        setupData()
    }
    
    func setupData() {
        getData().done { (data) in
            self.hideActivityIndicator()
            self.setupView(data: data)
            }.catch { error in
                let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.setupData()
        }
    }
    
    func getData() -> Promise<IntroductionViewModel> {
        let url = "http://104.199.252.182:9000/api/Beacon/introduction"
        return Promise () { resolver in
            AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success( _):
                if let model = Mapper<IntroductionViewModel>().map(JSONObject: response.value) {
                    resolver.fulfill(model)
                }
            case .failure(let error):
                resolver.reject(error)
            }
        }
        }
    }

    func setupView(data : IntroductionViewModel) {
        introductionLabel.text = "Introduction"
        descripLabel.text = data.intro_desc
        
        guard let url = URL(string: data.intro_img ?? "") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        imageView.image = UIImage(data: data)?.image(alpha: 0.16)
        
        continueButton.isHidden = false
    }

    @IBAction func continueButtonClicked(_ sender: Any) {
        let home = HomeViewController()
        let vc = UINavigationController(rootViewController: home)
        vc.modalPresentationStyle = .fullScreen
        
        var message = ""
        let preferredLanguage = NSLocale.preferredLanguages[0]
        if preferredLanguage == "en"  {
            message = "Application need to access your loacation and bluetooth. Please turn ON your GPS and Blutooth"
        } else {
            message = "แอพพลิเคชั่นมีความจำเป็นต้องเปิดใช้งานอินเทอร์เน็ต, gps และ bluetooth"
        }
        
        let alert = UIAlertController(title: message, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.present(vc, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)

    }
}
