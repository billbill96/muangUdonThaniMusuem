//
//  TopStoryViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 6/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PromiseKit

class TopStoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    let identifier = "cell"
    let cellHeight: CGFloat = 400
    var data : [TopStroyViewModel] = [] {
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
        
        setupData()
    }
    
    func setupData() {
        getData().done { (data) in
            self.data = data
            }.catch { error in
                let alert = UIAlertController(title: "Something went wrong!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.setupData()
        }
    }
    
    func getData() -> Promise<[TopStroyViewModel]>{
        let url = "http://104.199.252.182:9000/api/Beacon/top/stories"
        return Promise () { resolver in
            AF.request(url).responseJSON { (response) in
                switch response.result {
                case .success(let _):
                    if let model = Mapper<TopStroyViewModel>().mapArray(JSONObject: response.value) {
                        resolver.fulfill(model)
                    }
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
    }
}

extension TopStoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopStoryTableViewCell
        cell.setupCell(image: data[indexPath.row].topic_image ?? "", topic: data[indexPath.row].topic ?? "", time: "")
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = data[indexPath.row].topic ?? ""
        let image = data[indexPath.row].topic_image ?? ""
        let detail = data[indexPath.row].detail ?? ""
        
        let topStoryDescription = TopStoryDescriptionViewController(topic: topic, image: image, detail: detail,navTitle: "Top Stories")
        navigationController?.pushViewController(topStoryDescription, animated: true)
    }
}
