//
//  NotiDetailViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 12/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class NotiDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var firstTabBar: UITabBarItem!
    @IBOutlet weak var secondTabBar: UITabBarItem!
    @IBOutlet weak var thirdTabBar: UITabBarItem!
    @IBOutlet weak var contentView: UIView!
    
    weak var presentViewController: UIViewController?

    let cellHeight: CGFloat = 319
    var uuid: String = ""
    var viewModel: NotificationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        firstTabBar.tag = 1
        firstTabBar.image = UIImage(named: "icons8-home-filled-50")
        firstTabBar.title = "Home"
        secondTabBar.tag = 2
        secondTabBar.image = UIImage(named: "icons8-play-64")
        secondTabBar.title = "Video"
        thirdTabBar.tag = 3
        thirdTabBar.image = UIImage(named: "icons8-facebook-26")
        thirdTabBar.title = "Share"
        

        tableView.register(UINib(nibName: "NotiDetailViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = cellHeight
        
        getData(uuid: uuid)
    }
    
    func setNavigationBar(title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        let hStack = UIStackView(arrangedSubviews: [titleLabel])
        hStack.spacing = 10
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        navigationController?.navigationBar.barTintColor = AppsColor.red
        navigationController?.navigationBar.isTranslucent = false
    }

    func getData(uuid: String) {
        let url = "http://104.199.252.182:9000/api/Beacon/notification"
        AF.request(url, method: .get, parameters: ["id":uuid]).responseJSON { response in
            let model =  Mapper<NotificationModel>().mapArray(JSONObject: response.result.value)
            if let data = model {
                self.setupData(model: data)
            }else {
                
            }
        }
    }
    
    func setupData(model: [NotificationModel]) {
        var u_id : String = ""
        var notify: String = ""
        var topic: String = ""
        var b_id: Int = 0
        var image : [String] = []
        var image_detail: [String] = []
        var video : [String] = []
        var video_detail: [String] = []
        for data in model {
            u_id = data.u_id ?? ""
            notify = data.notify ?? ""
            topic = data.topic ?? ""
            b_id = data.b_id ?? 0
            
            image.append(data.img ?? "")
            image_detail.append(data.img_detail ?? "")
            
            video.append(data.video ?? "")
            video_detail.append(data.video_detail ?? "")
        }
        self.viewModel = NotificationViewModel(u_id: u_id, notify: notify, topic: topic, img: image, img_detail: image_detail, video: video, video_detail: video_detail, b_id: b_id)
        setNavigationBar(title: viewModel?.notify ?? "Detail")
        tableView.reloadData()
    }
    
    func setPresentViewController(viewController: UIViewController) {
        removeViewController(vc: presentViewController)
        tableView.isHidden = true
        presentViewController = viewController
        addViewController(vc: presentViewController)
    }
    
    func addViewController(vc: UIViewController?) {
        guard let viewController = vc ,let childView = viewController.view else { return }
        
        addChild(viewController)
        contentView.addSubview(childView)
        viewController.didMove(toParent: self)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: contentView.topAnchor),
            childView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            childView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            childView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }
    
    func removeViewController(vc : UIViewController?) {
        guard let viewController = vc else { return }
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

}

extension NotiDetailViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.img.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let viewModel = viewModel else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotiDetailViewCell
        cell.setupCell(img: viewModel.img[indexPath.row], topic: viewModel.topic, descrip: viewModel.img_detail[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension NotiDetailViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let homeVC = HomeViewController()
        let home = UINavigationController(rootViewController: homeVC)

        var video : [String] = []
        var videoDes: [String] = []
        var title: String = ""
        if let viewModel = viewModel {
            video = viewModel.video
            videoDes = viewModel.video_detail
            title = viewModel.topic
        }else {
            
        }
        
        let videoVC = VideoViewController(title: title, video: video, videoDescrip: videoDes)
        let shareVC = ShareViewController()
        
        if item.tag == 1 {
            self.present(home,animated: true)
        }else if item.tag == 2{
            setPresentViewController(viewController: videoVC)
        }else if item.tag == 3 {
            setPresentViewController(viewController: shareVC)
        }
    }
}
