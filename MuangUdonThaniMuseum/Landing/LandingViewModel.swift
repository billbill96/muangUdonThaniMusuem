//
//  LandingViewModel.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 11/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import Foundation
import ObjectMapper

struct LandingViewModel: Mappable {
    var id: Int?
    var start_desc: String?
    var start_img: String?
    var intro_desc: String?
    var intro_img: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["g_id"]
        start_desc <- map["g_start_desc"]
        start_img <- map["g_start_img"]
        intro_desc <- map["g_intro_desc"]
        intro_img <- map["g_intro_img"]
    }
   
}
