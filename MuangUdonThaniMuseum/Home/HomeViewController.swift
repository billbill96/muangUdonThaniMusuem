//
//  HomeViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 4/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import KontaktSDK
import Alamofire
import ObjectMapper
import UserNotifications
import CoreBluetooth

class HomeViewController: UIViewController,ActivityIndicatorPresenter {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topstoryMenuView: UIView!
    @IBOutlet weak var topStoryLabel: UILabel!
    @IBOutlet weak var topStoryLine: UIView!
    @IBOutlet weak var newsMenuView: UIView!
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var newsLine: UIView!
    @IBOutlet weak var mapMenuView: UIView!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapLine: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var didselect: [Bool] = [true,false,false]
    weak var presentViewController: UIViewController?
    
    var devicesManager: KTKDevicesManager!
    var beaconManager: KTKBeaconManager!
    var kontaktCloud: KTKCloudClient!
    var regions: [KTKBeaconRegion] = []
    var state: [CLRegionState] = []
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    var activityIndicator = UIActivityIndicatorView()
    var count = 0
    var timer = Timer()
    
    static var alreadyDiscover: [KTKBeaconRegion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }

        beaconManager = KTKBeaconManager(delegate: self)
        devicesManager = KTKDevicesManager(delegate: self)
        kontaktCloud = KTKCloudClient()
        
        showActivityIndicator()
        
        getAllBeacon() { regionss in
            self.view.isUserInteractionEnabled = true
            switch KTKBeaconManager.locationAuthorizationStatus() {
            case .notDetermined:
                self.beaconManager.requestLocationAlwaysAuthorization()
            case .denied, .restricted:
                break
            case .authorizedWhenInUse:
                print("when in use")
                if KTKBeaconManager.isMonitoringAvailable() {
                    self.devicesManager.startDevicesDiscovery()
                    for region in regionss {
                        self.beaconManager.startMonitoring(for: region)
                    }
                }
            case .authorizedAlways:
                 print("authorizedAlways")
                if KTKBeaconManager.isMonitoringAvailable() {
                    self.devicesManager.startDevicesDiscovery()
                    for region in regionss {
//                        self.beaconManager.startRangingBeacons(in: region)
                        self.beaconManager.startMonitoring(for: region)
                    }
                }
            @unknown default:
                break
            }
            
            for region in regionss {
                self.beaconManager.requestState(for: region)
            }
            self.hideActivityIndicator()
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }

        setupNavigation()
        setupStackView()
        
        setPresentViewController(viewController: TopStoryViewController())
        self.view.isUserInteractionEnabled = false
        
    }
    
    func setupNavigation() {
        let imageView = UIImageView()
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 17),
            imageView.widthAnchor.constraint(equalToConstant: 17)
            ])
        imageView.image = UIImage(named: "icons8-home-filled-50-white")
        
        let titleLabel = UILabel()
        titleLabel.text = "Home"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        let hStack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        hStack.spacing = 10
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        navigationController?.navigationBar.barTintColor = AppsColor.red
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupStackView() {
        topstoryMenuView.backgroundColor = AppsColor.red
        newsMenuView.backgroundColor = AppsColor.red
        newsLine.backgroundColor = .yellow
        mapMenuView.backgroundColor = AppsColor.red
        setupLineView()
        topstoryMenuView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(topStoryClicked(_:)))
        topstoryMenuView.addGestureRecognizer(gesture)
        newsMenuView.isUserInteractionEnabled = true
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(newsClicked(_:)))
        newsMenuView.addGestureRecognizer(gesture2)
        mapMenuView.isUserInteractionEnabled = true
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(mapClicked(_:)))
        mapMenuView.addGestureRecognizer(gesture3)
    }
    
    func setupLineView() {
        if didselect[0] {
            topStoryLine.backgroundColor = .yellow
            newsLine.backgroundColor = .clear
            mapLine.backgroundColor = .clear
        }
        if didselect[1] {
            newsLine.backgroundColor = .yellow
            topStoryLine.backgroundColor = .clear
            mapLine.backgroundColor = .clear
        }
        if didselect[2] {
            mapLine.backgroundColor = .yellow
            topStoryLine.backgroundColor = .clear
            newsLine.backgroundColor = .clear
        }
    }
    
    @objc func topStoryClicked(_ sender: UITapGestureRecognizer) {
        didselect = [true,false,false]
        setupLineView()
        setPresentViewController(viewController: TopStoryViewController())
    }
    
    @objc func newsClicked(_ sender: UITapGestureRecognizer) {
        didselect = [false,true,false]
        setupLineView()
        setPresentViewController(viewController: NewsViewController())
    }
    
    @objc func mapClicked(_ sender: UITapGestureRecognizer) {
        didselect = [false,false,true]
        setupLineView()
        setPresentViewController(viewController: MapViewController())
    }
    
    func setPresentViewController(viewController: UIViewController) {
        removeViewController(vc: presentViewController)
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
    
    func getNotification(uuid: String) {
        print("in app noti")
        let url = "http://104.199.252.182:9000/api/Beacon/notification"
        AF.request(url, method: .get, parameters: ["id":uuid.lowercased()]).responseJSON { response in
            let model =  Mapper<NotificationModel>().map(JSONObject: response.value)
            if let data = model {
                if data.notify != "" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.createLocalNotification(title: data.notify ?? "", uuid: uuid)
                    }
                }
            }else {
            }
        }
    }
    
    func createLocalNotification(title: String, uuid: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.body = "Tap to view more inforformation of the room"
        content.userInfo = ["uuid": uuid] as [String:String]
//        count += 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(uuid)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
       
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print(requests)
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getState2), userInfo: nil, repeats: true)
    }

    @objc func getState2() {
        state.removeAll()
        for region in regions {
            beaconManager.requestState(for: region)
        }
    }
    
    func getState(completion: @escaping ([CLRegionState]) -> ()) {
        state.removeAll()
        for region in regions {
            beaconManager.requestState(for: region)
        }
        completion(self.state)
    }
    
    func getAllBeacon(completion: @escaping ([KTKBeaconRegion]) -> ()) {
        let apiClient1 = KTKCloudClient()
        let tags = ["test"]
        apiClient1.getObjects(KTKDevice.self) {
            response, error in
            if let devices = response?.objects as? [KTKDevice] {
                for device in devices {
                    if device.tags == tags {
                        let major = UInt16(truncating: device.configuration.major ?? 0)
                        let minor = UInt16(truncating: device.configuration.minor ?? 0)
                        let uuid = device.configuration.proximityUUID
                        let unique = device.uniqueID
                        let region = KTKBeaconRegion(proximityUUID: uuid! ,major: major, minor: minor, identifier: unique)
                        print(region)
                        self.regions.append(region)
                    }
                }
                completion(self.regions)
            }
        }
    }
}

extension HomeViewController: KTKDevicesManagerDelegate {
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        getState { (state) in
            for device in devices {
                print("unique \(device.uniqueID)")
                for region in self.regions {
                    if region.identifier == device.uniqueID {
                        print("getnotification \(region.identifier)")
//                        var uuid = "f2826da6-4fa2-4e98-8024-bc5b71e00016"
//                        self.getNotification(uuid: uuid)
                        if !HomeViewController.alreadyDiscover.contains(region) {
                            HomeViewController.alreadyDiscover.append(region)
                            self.getNotification(uuid: "\(region.proximityUUID)")
//                            self.getNotification(uuid: uuid)
                        }
                    }
                }
            }
        }
        
        for already in HomeViewController.alreadyDiscover {
            print("already \(already)")
        }
    }
}

extension HomeViewController: KTKBeaconManagerDelegate {
    func beaconManager(_ manager: KTKBeaconManager, didDetermineState state: CLRegionState, for region: KTKBeaconRegion) {
        //case 0 unknow case 1 inside , case 2 outside
        print("state \(state.rawValue) \(region.identifier)")
        self.state.append(state)
        if state.rawValue == 2 || state.rawValue == 0 {
            for already in HomeViewController.alreadyDiscover {
                if already.proximityUUID == region.proximityUUID {
                    if let index = HomeViewController.alreadyDiscover.index(of: already) {
                        HomeViewController.alreadyDiscover.remove(at: index)
                        print("remove")
                    }
                }
            }
        }
    }

    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if KTKBeaconManager.isMonitoringAvailable() {
                if regions.count > 0 {
                    print("start monitoring")
                    for region in regions {
                        beaconManager.startMonitoring(for: region)
                        devicesManager.startDevicesDiscovery()
                    }
                }
            }
        } else if status == .authorizedWhenInUse {
            if KTKBeaconManager.isMonitoringAvailable() {
                if regions.count > 0 {
                    print("start authorizedWhenInUse")
                    for region in regions {
                        beaconManager.startMonitoring(for: region)
                        devicesManager.startDevicesDiscovery()
                    }
                }
            }
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        print("----------------Ente rregion \(region)")
//        getNotification(uuid: "\(region.proximityUUID)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        for already in HomeViewController.alreadyDiscover {
            if already.proximityUUID == region.proximityUUID {
                if let index = HomeViewController.alreadyDiscover.index(of: already) {
//                    HomeViewController.alreadyDiscover.remove(at: index)
//                    print("remove")
                }
            }
        }
        print("Exit region \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        if beacons.count > 0 {
            beaconManager.stopRangingBeacons(in: region)
            for beacon in beacons {
                let uuid = "\(beacon.proximityUUID)"
                print("raging \(uuid)")
                getNotification(uuid: uuid)
            }
        }
    }
}
