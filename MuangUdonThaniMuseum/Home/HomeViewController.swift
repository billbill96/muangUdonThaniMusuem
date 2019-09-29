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

class HomeViewController: UIViewController {
    
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
    var regions : [KTKBeaconRegion] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beaconManager = KTKBeaconManager(delegate: self)
        devicesManager = KTKDevicesManager(delegate: self)
        kontaktCloud = KTKCloudClient()
        
        getAllBeacon() { regionss in
            switch KTKBeaconManager.locationAuthorizationStatus() {
            case .notDetermined:
                self.beaconManager.requestLocationAlwaysAuthorization()
            case .denied, .restricted:
                break
            case .authorizedWhenInUse:
                break
            case .authorizedAlways:
                 print("start monitoring")
                if KTKBeaconManager.isMonitoringAvailable() {
                    for region in regionss {
                        self.beaconManager.startMonitoring(for: region)
                    }
                }
    //            devicesManager.startDevicesDiscovery()
            @unknown default:
                break
            }
            
            for region in regionss {
                self.beaconManager.requestState(for: region)
            }

        }
        

        
        let myProximityUuid = UUID(uuidString: "481addf5-b65d-45af-8c48-8b2aa42b7fa3")
        let region = KTKBeaconRegion(proximityUUID: myProximityUuid!, identifier: "Beacon region")
        
//        devicesManager.startDevicesDiscovery()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }

        setupNavigation()
        setupStackView()
        
        setPresentViewController(viewController: TopStoryViewController())
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
        let url = "http://104.199.252.182:9000/api/Beacon/notification"
        AF.request(url, method: .get, parameters: ["id":uuid.lowercased()]).responseJSON { response in
            let model =  Mapper<NotificationModel>().map(JSONObject: response.value)
            if let data = model {
                if data.notify != "" {
                    self.createLocalNotification(title: data.notify ?? "", uuid: uuid)
                }
            }else {
            }
        }
    }
    
    func createLocalNotification(title: String, uuid: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.userInfo = ["uuid": uuid] as [String:String]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func getAllBeacon(completion: @escaping ([KTKBeaconRegion]) -> ()) {
        let apiClient1 = KTKCloudClient()
        apiClient1.getObjects(KTKDevice.self) {
            response, error in
            if let devices = response?.objects as? [KTKDevice] {
                var count = 0
                for device in devices {
                    count += 1
                    if device.uniqueID.count < 10 {
                        let major = UInt16(truncating: device.configuration.major ?? 0)
                        let minor = UInt16(truncating: device.configuration.minor ?? 0)
                        let uuid = device.configuration.proximityUUID
                        let region = KTKBeaconRegion(proximityUUID: uuid! ,major: major, minor: minor, identifier: "Beacon region \(count)")
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
        devicesManager.stopDevicesDiscovery()
        for device in devices {
            print(device.peripheral.identifier)
            let uuid = "\(device.peripheral.identifier)"
//            getNotification(uuid: uuid)
        }
    }
}

extension HomeViewController: KTKBeaconManagerDelegate {
    func beaconManager(_ manager: KTKBeaconManager, didDetermineState state: CLRegionState, for region: KTKBeaconRegion) {
        print("in state \(state.rawValue) \(region)")
        if state.rawValue == 1 {
//            beaconManager.startRangingBeacons(in: region)
        }
    }

    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if KTKBeaconManager.isMonitoringAvailable() {
                if regions.count > 0 {
                    print("start monitoring")
                    for region in regions {
                        beaconManager.startMonitoring(for: region)
                    }
                }
            }
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        getNotification(uuid: "\(region.proximityUUID)")
        print("Enter region \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        print("Exit region \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        if beacons.count > 0 {
            beaconManager.stopMonitoring(for: region)
            beaconManager.stopRangingBeacons(in: region)
            for beacon in beacons {
                let uuid = "\(beacon.proximityUUID)"
                getNotification(uuid: uuid)
            }
        }
    }
}
