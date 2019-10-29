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
    static var regions: [KTKBeaconRegion] = []
    var state: [CLRegionState] = []
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    var activityIndicator = UIActivityIndicatorView()
    var count = 0
    var timer = Timer()
    var timeStampExit = Date()
    var timeStampEnter = Date().addingTimeInterval(2)
    var justExitBool: Bool = false

    static var firstLoad: Bool = true
    static var alreadyDiscover: [String] = []
    static var lastedTime: [String: Double] = [:]
    static var foundTime: [String: Double] = [:]
    
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
        
        if HomeViewController.regions.count < 1 {
            self.view.isUserInteractionEnabled = false

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
                        for region in regionss {
                            self.beaconManager.startRangingBeacons(in: region)
    //                        self.beaconManager.startMonitoring(for: region)
                        }
                    }
                case .authorizedAlways:
                     print("authorizedAlways")
                    if KTKBeaconManager.isMonitoringAvailable() {
                        for region in regionss {
                            self.beaconManager.startRangingBeacons(in: region)
                            self.beaconManager.startMonitoring(for: region)
                        }
                    }
                @unknown default:
                    break
                }
                self.hideActivityIndicator()
                
                if regionss.count < 1 {
                    let alert = UIAlertController(title: "Something went wrong!", message: "Can't get region for beacon.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        setupNavigation()
        setupStackView()
        
        setPresentViewController(viewController: TopStoryViewController())
        
        HomeViewController.firstLoad = false
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
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        HomeViewController.alreadyDiscover.append(identifier)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if error != nil {
              print("error notification \(error)")
            }
        })
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print(requests)
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getState2), userInfo: nil, repeats: true)
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
    
    @objc func getState2() {
        self.state.removeAll()
        for region in HomeViewController.regions {
            beaconManager.requestState(for: region)
        }
    }
    
    func getState(completion: @escaping ([CLRegionState]) -> ()) {
        self.state.removeAll()
        for region in HomeViewController.regions {
            beaconManager.requestState(for: region)
        }
        completion(self.state)
    }
    
    func getAllBeacon(completion: @escaping ([KTKBeaconRegion]) -> ()) {
        let apiClient1 = KTKCloudClient()
        let tags = ["test"]
        var count = 0
        apiClient1.getObjects(KTKDevice.self) {
            response, error in
            if let devices = response?.objects as? [KTKDevice] {
                for device in devices {
                    if device.tags == tags {
                        count += 1
                        let major = UInt16(truncating: device.configuration.major ?? 0)
                        let minor = UInt16(truncating: device.configuration.minor ?? 0)
                        let uuid = device.configuration.proximityUUID
                        let unique = "\(device.uniqueID)\(count)"
                        let region = KTKBeaconRegion(proximityUUID: uuid! ,major: major, minor: minor, identifier: unique)
                        print(region)
                        HomeViewController.regions.append(region)
                        HomeViewController.lastedTime[unique] = 0.0
                        HomeViewController.foundTime[unique] = 0.0
                        print(HomeViewController.lastedTime[unique])
                        region.notifyOnExit = true
                        region.notifyOnEntry = true
                        region.notifyEntryStateOnDisplay = true
                    }
                }
                completion(HomeViewController.regions)
            }
        }
    }
}

extension HomeViewController: KTKDevicesManagerDelegate {
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        for device in devices {
            print("unique \(device.uniqueID)")
            var count = 0
            for region in HomeViewController.self.regions {
                count += 1
                if "\(region.identifier)\(count)" == device.uniqueID {
                    print("getnotification \(region.identifier)")
                    if !HomeViewController.alreadyDiscover.contains(region.identifier) {
                        self.getNotification(uuid: "\(region.proximityUUID)", identifier: region.identifier)
                    }
                }
            }
        }
    }
}

extension HomeViewController: KTKBeaconManagerDelegate {
    func beaconManager(_ manager: KTKBeaconManager, didDetermineState state: CLRegionState, for region: KTKBeaconRegion) {
        //case 0 unknow case 1 inside , case 2 outside
        if !HomeViewController.firstLoad {
            NSLog("state \(state.rawValue) \(region.identifier)")

            if state.rawValue == 2 {
                for already in HomeViewController.alreadyDiscover {
                    if already == region.identifier {
                        if let index = HomeViewController.alreadyDiscover.index(of: already) {
                            HomeViewController.lastedTime[region.identifier] = Date().timeIntervalSince1970
                            guard let last = HomeViewController.foundTime[region.identifier] else { return }
                            let dateUX = Date(timeIntervalSince1970: last)
                            let diff = Date().timeIntervalSince(dateUX)
                             if diff > 10  && diff < 1000 {
                                HomeViewController.alreadyDiscover.remove(at: index)
                                print("remove state state \(region.identifier) \(HomeViewController.lastedTime[region.identifier])")

                            }
                        }
                    }
                }
            } else if state.rawValue == 1 {
                HomeViewController.foundTime[region.identifier] = Date().timeIntervalSince1970
                if !HomeViewController.alreadyDiscover.contains(region.identifier) {
                    NSLog("founded in state \(region.identifier)")
                    self.getNotification(uuid: "\(region.proximityUUID)", identifier: region.identifier)
                }
            }
        }
        self.state.append(state)
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
        
        timeStampEnter = Date()
        
        beaconManager.requestState(for: region)
        print("enterr \(timeStampEnter)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        timeStampExit = Date()
        NSLog("exitn now \(timeStampExit)")
        NSLog("Exit region \(region)")
        
        beaconManager.requestState(for: region)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
                let proximity = beacon.proximity
                HomeViewController.foundTime[region.identifier] = Date().timeIntervalSince1970
                NSLog("ranging \(beacon.proximityUUID) \(proximity.stringValue)")
                if !HomeViewController.alreadyDiscover.contains(region.identifier) {
                    NSLog("founded \(region.identifier)")
                    self.getNotification(uuid: "\(region.proximityUUID)", identifier: region.identifier)
                }
            }
        } else {
            for already in HomeViewController.alreadyDiscover {
                if already == region.identifier {
                    print("notfound \(region.identifier)")
                    if let index = HomeViewController.alreadyDiscover.index(of: already) {
                        HomeViewController.lastedTime[region.identifier] = Date().timeIntervalSince1970
                        
                        guard let last = HomeViewController.foundTime[region.identifier] else { return }
                        let dateUX = Date(timeIntervalSince1970: last)
                        let diff = Date().timeIntervalSince(dateUX)
                        print("diff \(diff) \(region.identifier)")
                         if diff > 10  && diff < 1000 {
                            HomeViewController.alreadyDiscover.remove(at: index)
                            NSLog("remove state raging \(region.identifier) \(HomeViewController.lastedTime[region.identifier])")
                        }
                    }
                }
            }
        }
    }
}

enum NSComparisonResult : Int {
    case OrderedAscending
    case OrderedSame
    case OrderedDescending
}
