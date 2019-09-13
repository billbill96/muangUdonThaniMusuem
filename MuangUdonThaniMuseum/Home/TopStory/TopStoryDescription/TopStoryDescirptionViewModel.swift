//
//  TopStoryDescirptionViewModel.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 12/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import Foundation
import ObjectMapper

struct TopStroyViewModel: Mappable {
    var id: Int?
    var topic_image: String?
    var topic: String?
    var detail: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["topic_id"]
        topic_image <- map["topic_image"]
        topic <- map["topic"]
        detail <- map["detail"]
    }
    
}
