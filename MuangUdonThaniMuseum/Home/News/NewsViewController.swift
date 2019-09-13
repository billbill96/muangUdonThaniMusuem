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

class NewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let identifier = "cell"
    let cellHeight: CGFloat = 400
    var data : [NewViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "TopStoryTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = cellHeight

        getData()
    }


    func getData() {
        let url = "http://104.199.252.182:9000/api/Beacon/news"
        AF.request(url).responseJSON { (response) in
            let model =  Mapper<NewViewModel>().mapArray(JSONObject: response.result.value)
            if let viewModel = model {
                self.data = viewModel
            }else {
                //TOOD: handle data
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
        cell.setupCell(image: data[indexPath.row].image ?? "", topic: data[indexPath.row].topic ?? "", time: "6 hours ago")
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        return cell

    }
    
}
