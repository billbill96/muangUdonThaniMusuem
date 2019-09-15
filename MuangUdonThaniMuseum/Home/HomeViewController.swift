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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        beaconManager = KTKBeaconManager(delegate: self)
        devicesManager = KTKDevicesManager(delegate: self)
        
        let myProximityUuid = UUID(uuidString: "F7826DA6-4FA2-4E98-8024-BC5B71E0893E")
        let region = KTKBeaconRegion(proximityUUID: myProximityUuid!,major: 3424, minor: 54960, identifier: "Beacon region 1")
        let region2 = KTKBeaconRegion(proximityUUID: myProximityUuid!,major: 28538, minor: 40233, identifier: "Beacon region 2")

        beaconManager.requestState(for: region2)
        switch KTKBeaconManager.locationAuthorizationStatus() {
        case .notDetermined:
            beaconManager.requestLocationAlwaysAuthorization()
        case .denied, .restricted:
            break
        case .authorizedWhenInUse:
            break
        case .authorizedAlways:
            if KTKBeaconManager.isMonitoringAvailable() {
                beaconManager.startMonitoring(for: region)
                beaconManager.startMonitoring(for: region2)
            }
        @unknown default:
            break
        }
        
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
        devicesManager.stopDevicesDiscovery()
        let url = "http://104.199.252.182:9000/api/Beacon/notification"
        AF.request(url, method: .get, parameters: ["id":uuid]).responseJSON { response in
            let model =  Mapper<NotificationModel>().mapArray(JSONObject: response.result.value)
            if let data = model?[0] {
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
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension HomeViewController: KTKDevicesManagerDelegate {
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        devicesManager.stopDevicesDiscovery()
        for device in devices {
            print(device.peripheral.identifier)
            var uuid = "\(device.peripheral.identifier)"
            uuid = uuid.replacingOccurrences(of: "-", with: "").lowercased()
            getNotification(uuid: "980dc4e81fec52199cbf2d930b8e2326")
        }
    }
}

extension HomeViewController: KTKBeaconManagerDelegate {
    func beaconManager(_ manager: KTKBeaconManager, didDetermineState state: CLRegionState, for region: KTKBeaconRegion) {
        print("in state \(region)")
    }

    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        devicesManager.startDevicesDiscovery()
        print("Enter region \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        beaconManager.stopRangingBeacons(in: region)
        print("Exit region \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
                print("\(beacon)")
            }
        }
    }
}
