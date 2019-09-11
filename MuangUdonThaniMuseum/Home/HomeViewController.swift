//
//  HomeViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 4/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import KontaktSDK

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
        beaconManager.requestLocationAlwaysAuthorization()
        
        let proximityUUID = NSUUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let region = KTKBeaconRegion(proximityUUID: proximityUUID! as UUID,
                                     identifier: "region-identifier")
        
        beaconManager.startMonitoring(for: region)
        beaconManager.startRangingBeacons(in: region)
        
        devicesManager = KTKDevicesManager(delegate: self)
        
//        devicesManager.startDevicesDiscovery(withInterval: 2.0)

        setupNavigation()
        setupStackView()
        
        setPresentViewController(viewController: TopStoryViewController())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)//UIFont(name: "Roboto-Bold", size: 20)
        
        
        let hStack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        hStack.spacing = 10
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        navigationController?.navigationBar.barTintColor = AppsColor.red
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
}

extension HomeViewController: KTKDevicesManagerDelegate {
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
//        for device in devices {
//            print(device)
//        }
    }
}

extension HomeViewController: KTKBeaconManagerDelegate {
    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        // Do something when monitoring for a particular
        // region is successfully initiated
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        // Decide what to do when a user enters a range of your region; usually used
        // for triggering a local notification and/or starting a beacon ranging
        print("Enter region \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        // Decide what to do when a user exits a range of your region; usually used
        // for triggering a local notification and stoping a beacon ranging
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
