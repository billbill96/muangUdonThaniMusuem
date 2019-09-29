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

class IntroductionViewController: UIViewController {
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var vSpinner : UIView?

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
        
        continueButton.isHidden = true
        self.showSpinner(onView: self.view)
        getData().done { (data) in
            self.removeSpinner()
            self.setupView(data: data)
            }.catch { error in
                let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func getData() -> Promise<IntroductionViewModel> {
        let url = "http://104.199.252.182:9000/api/Beacon/introduction"
        return Promise () { resolver in
            AF.request(url, method: .get, parameters: ["id":1]).responseJSON { response in
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
       
        let alert = UIAlertController(title: "Permission", message: "To use this app you should allow .... ", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.present(vc, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)

    }
}

extension IntroductionViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = view.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}
