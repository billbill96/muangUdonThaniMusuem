//
//  IntroductionViewModel.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 11/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import Foundation
import ObjectMapper

struct IntroductionViewModel: Mappable {
    var id: Int?
    var intro_desc: String?
    var intro_img: String?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["g_id"]
        intro_desc <- map["g_intro_desc"]
        intro_img <- map["g_intro_img"]
    }
}
