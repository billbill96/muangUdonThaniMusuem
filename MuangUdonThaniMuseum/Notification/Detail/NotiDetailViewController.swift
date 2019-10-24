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
import PromiseKit
import FBSDKShareKit
import KontaktSDK
import UserNotifications

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
    var vSpinner : UIView?
    
    var devicesManager: KTKDevicesManager!
    var beaconManager: KTKBeaconManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        firstTabBar.tag = 1
        secondTabBar.tag = 2
        thirdTabBar.tag = 3
        
        tableView.register(UINib(nibName: "NotiDetailViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = cellHeight
        tableView.separatorStyle = .none
        
        setupData()
        tabBar.selectedItem = .none
        
        beaconManager = KTKBeaconManager(delegate: self)
        devicesManager = KTKDevicesManager(delegate: self)
        
        for region in HomeViewController.regions {
            beaconManager.startMonitoring(for: region)
            beaconManager.startRangingBeacons(in: region)
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBar.selectedItem = .none
    }
    
    @objc func appMovedToBackground() {
        print("move background function")
        devicesManager.startDevicesDiscovery(withInterval: 3.0)
    }
    
    @objc func willEnterForeground() {
        devicesManager.stopDevicesDiscovery()
        for region in HomeViewController.regions {
            beaconManager.startMonitoring(for: region)
            beaconManager.startRangingBeacons(in: region)
        }
    }
    
    func setupData() {
        getData(uuid: uuid).done { (data) in
            self.setupData(model: data)
            }.catch { error in
                let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.setupData()
        }
    }
    
    func setNavigationBar(title: String) {
        let titleLabel = UILabel()
        titleLabel.text = "Detail"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        let hStack = UIStackView(arrangedSubviews: [titleLabel])
        hStack.spacing = 10
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        navigationController?.navigationBar.barTintColor = AppsColor.red
        navigationController?.navigationBar.isTranslucent = false
    }

    func getData(uuid: String) -> Promise<NotificationModel>{
        let url = "http://104.199.252.182:9000/api/Beacon/notification"
        return Promise() { resolver in
            AF.request(url, method: .get, parameters: ["id":uuid]).responseJSON { response in
                switch response.result{
                case .success(let _):
                    if let model =  Mapper<NotificationModel>().map(JSONObject: response.value) {
                        resolver.fulfill(model)
                    }
                case .failure(let error):
                    resolver.reject(error)
                }
            }

        }
    }
    
    func setupData(model: NotificationModel) {
        var u_id : String = ""
        var notify: String = ""
        var topic: String = ""
        var b_id: Int = 0
        var image : [String] = []
        var image_detail: [String] = []
        var video : [String] = []
        var video_detail: [String] = []
        var share_url: String = ""
        var facebook_name: String = ""
        
        u_id = model.u_id ?? ""
        notify = model.notify ?? ""
        topic = model.topic ?? ""
        b_id = model.b_id ?? 0
        share_url = model.share_url ?? ""
        facebook_name = model.facebook_name ?? ""
        
        if let videos = model.video ?? nil {
            for vd in videos {
                video.append(vd.video ?? "")
                video_detail.append(vd.video_detail ?? "")
            }
        }

        if let images = model.image ?? nil {
            for img in images {
                image.append(img.image ?? "")
                image_detail.append(img.image_detail ?? "")
            }
        }
        self.viewModel = NotificationViewModel(u_id: u_id, notify: notify, topic: topic, img: image, img_detail: image_detail, video: video, video_detail: video_detail, b_id: b_id, share_url:share_url, facebook_name: facebook_name)
        setNavigationBar(title: viewModel?.notify ?? "Detail")
        if share_url == "" {
            thirdTabBar.isEnabled = false
        }
        tableView.reloadData()
    }
    
    func getNotification(uuid: String, identifier: String) {
        print("in app noti \(identifier) \(uuid.lowercased())")
        let url = "http://104.199.252.182:9000/api/Beacon/notification"
        AF.request(url, method: .get, parameters: ["id":uuid.lowercased()]).responseJSON { response in
            let model =  Mapper<NotificationModel>().map(JSONObject: response.value)
            if let data = model {
                if data.notify != "" {
                    print("\(String(describing: data.notify))")
                    self.createLocalNotification(title: data.notify ?? "", uuid: uuid, identifier: identifier)
                }
            }
            else {
                print("errrrror")
            }
        }
    }
    
    func createLocalNotification(title: String, uuid: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.body = "Tap to view more inforformation of the room"
        content.userInfo = ["uuid": uuid] as [String:String]
//        count += 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
       
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print(requests)
        }
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
        var share_url : String = ""
        var navBarTitle: String = "Detail"
        var facebook_name: String = ""
        
        if let viewModel = viewModel {
            video = viewModel.video
            videoDes = viewModel.video_detail
            title = viewModel.topic
            share_url = viewModel.share_url
            navBarTitle = viewModel.notify
            facebook_name = viewModel.facebook_name
        }else {
            let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let videoVC = VideoViewController(title: title, video: video, videoDescrip: videoDes, shareUrl: share_url,facebook_name: facebook_name)
        videoVC.navTitle = "Detail"
        
        if item.tag == 1 {
            home.modalPresentationStyle = .fullScreen
            self.present(home,animated: true)
        }else if item.tag == 2{
            self.navigationController?.pushViewController(videoVC, animated: true)
        }else if item.tag == 3 {
            if share_url != "" {
                let content = ShareLinkContent()
                if let url =  URL(string: share_url.replacingOccurrences(of: " ", with: "")) {
                    content.contentURL =  url
                    let name = facebook_name.replacingOccurrences(of: "@", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "#", with: "")
                    content.hashtag = Hashtag("#\(name)")
                    
                    let dialog : ShareDialog = ShareDialog()
                    dialog.fromViewController = self
                    dialog.shareContent = content
                    dialog.delegate = self
                    let facebookURL = NSURL(string: "fbauth2://app")
                    if(UIApplication.shared.canOpenURL(facebookURL! as URL)){
                        dialog.mode = ShareDialog.Mode.native
                    }else{
                        dialog.mode = ShareDialog.Mode.feedWeb
                    }
                    dialog.show()
                }else {
                    let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension NotiDetailViewController: SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("share complete")
        tabBar.selectedItem = .none
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("share fail")
        tabBar.selectedItem = .none
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("share cancel")
        tabBar.selectedItem = .none
    }
}


extension NotiDetailViewController: KTKDevicesManagerDelegate {
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        for device in devices {
            print("unique \(device.uniqueID)")
            var count = 0
            for region in HomeViewController.self.regions {
                count += 1
                if "\(region.identifier)\(count)" == device.uniqueID {
                    print("getnotification \(region.identifier)")
                    if !HomeViewController.alreadyDiscover.contains(region.identifier) {
                        HomeViewController.alreadyDiscover.append(region.identifier)
                        self.getNotification(uuid: "\(region.proximityUUID)", identifier: region.identifier)
                    }
                }
            }
        }
    }
}

extension NotiDetailViewController: KTKBeaconManagerDelegate {
    func beaconManager(_ manager: KTKBeaconManager, didDetermineState state: CLRegionState, for region: KTKBeaconRegion) {
        //case 0 unknow case 1 inside , case 2 outside
        NSLog("state \(state.rawValue) \(region.identifier)")
        if state.rawValue == 2 {
            for already in HomeViewController.alreadyDiscover {
                if already == region.identifier {
                    if let index = HomeViewController.alreadyDiscover.index(of: already) {
                        HomeViewController.alreadyDiscover.remove(at: index)
                        print("remove state \(region.identifier)")
                    }
                }
            }
        } else if state.rawValue == 1 {
            if !HomeViewController.alreadyDiscover.contains(region.identifier) {
                let calendar = Calendar.current
                
                HomeViewController.alreadyDiscover.append(region.identifier)
                self.getNotification(uuid: "\(region.proximityUUID)", identifier: region.identifier)
            }
        }
//        self.state.append(state)
    }

    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if KTKBeaconManager.isMonitoringAvailable() {
                if HomeViewController.regions.count > 0 {
                    print("start monitoring")
                    for region in HomeViewController.regions {
                        beaconManager.startMonitoring(for: region)
                        beaconManager.startRangingBeacons(in: region)
                    }
                }
            }
        } else if status == .authorizedWhenInUse {
            if KTKBeaconManager.isMonitoringAvailable() {
                if HomeViewController.regions.count > 0 {
                    print("start authorizedWhenInUse")
                    for region in HomeViewController.regions {
//                        beaconManager.startMonitoring(for: region)
                        beaconManager.startRangingBeacons(in: region)
                    }
                }
            }
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        NSLog("----------------Enter region \(region)")
        
        
        beaconManager.requestState(for: region)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        NSLog("Exit region \(region)")
        
        beaconManager.requestState(for: region)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
                let proximity = beacon.proximity
                NSLog("ranging \(beacon.proximityUUID) \(proximity.stringValue)")
                
                if !HomeViewController.alreadyDiscover.contains(region.identifier) {
                    HomeViewController.alreadyDiscover.append(region.identifier)
                    self.getNotification(uuid: "\(region.proximityUUID)", identifier: region.identifier)
                }
            }
        } else {
            for already in HomeViewController.alreadyDiscover {
                if already == region.identifier {
                    if let index = HomeViewController.alreadyDiscover.index(of: already) {
                        HomeViewController.alreadyDiscover.remove(at: index)
                        print("remove state raging \(region.identifier)")
                    }
                }
            }
        }
    }
}

