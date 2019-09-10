//
//  TopStoryViewController.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 6/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit

class TopStoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let identifier = "cell"
    let cellHeight: CGFloat = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "TopStoryTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = cellHeight
    }
    
    
}

extension TopStoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopStoryTableViewCell
        cell.setupCell(image: "https://f.ptcdn.info/528/058/000/pbl2puvqmiWhzv01YO4-o.jpg", topic: "The Rachinuthit Building used as a building for the promotion of women's culture", time: "6 hours ago")
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topStoryDescription = TopStoryDescriptionViewController()
        let childNavigation = UINavigationController(rootViewController: topStoryDescription)
//        self.present(childNavigation, animated: true, completion: nil)
        navigationController?.pushViewController(topStoryDescription, animated: true)
        
    }
}
