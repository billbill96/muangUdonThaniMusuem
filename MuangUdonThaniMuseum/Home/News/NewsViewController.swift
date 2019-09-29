//
//  NewsViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 7/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PromiseKit

class NewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let identifier = "cell"
    let cellHeight: CGFloat = 400
    var data : [NewViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var vSpinner : UIView?


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "TopStoryTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = cellHeight
        tableView.tableFooterView = UIView()
        
//        self.showSpinner(onView: self.view)
        getData().done { (data) in
            self.data = data
//            self.removeSpinner()
            }.catch { error in
                let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }

    }

    func getData() -> Promise<[NewViewModel]> {
        let url = "http://104.199.252.182:9000/api/Beacon/news"
        return Promise() { resolver in
            AF.request(url).responseJSON { (response) in
                switch response.result{
                case .success( _):
                    if let model =  Mapper<NewViewModel>().mapArray(JSONObject: response.value) {
                        resolver.fulfill(model)
                    }
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
    }
}

extension NewsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopStoryTableViewCell
        cell.setupCell(image: data[indexPath.row].image ?? "", topic: data[indexPath.row].topic ?? "", time: "")
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        return cell

    }
    
}

extension NewsViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.frame)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = CGPoint(x: spinnerView.frame.width/2, y: spinnerView.frame.height/2 - 150)
        
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
