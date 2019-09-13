//
//  NewsViewModel.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 12/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import Foundation
import ObjectMapper

struct NewViewModel : Mappable{
    var id: Int?
    var image: String?
    var topic: String?
    var detail: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["news_id"]
        image <- map["news_image"]
        topic <- map["news_topic"]
        detail <- map["news_detail"]
    }
}
