//
//  NotificationModel.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 12/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import Foundation
import ObjectMapper

struct NotificationModel: Mappable {
    var u_id: String?
    var notify: String?
    var topic: String?
    var image: [imageObject]?
    var video: [videoObejct]?
    var b_id: Int?
    var share_url: String?
    var facebook_name: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        u_id <- map["u_id"]
        notify <- map["beacon_notify"]
        topic <- map["beacon_topic"]
        image <- map["img_dep"]
        video <- map["vdo_dep"]
        b_id <- map["b_id"]
        share_url <- map["beacon_share_url"]
        facebook_name <- map["facebook_name"]
    }
}

struct NotificationViewModel {
    var u_id: String
    var notify: String
    var topic: String
    var img: [String]
    var img_detail: [String]
    var video: [String]
    var video_detail: [String]
    var b_id: Int
    var share_url: String
    var facebook_name: String
    
    init(u_id: String, notify: String, topic: String, img: [String], img_detail: [String], video: [String], video_detail: [String], b_id: Int, share_url: String, facebook_name: String) {
        self.u_id = u_id
        self.notify = notify
        self.topic = topic
        self.img = img
        self.img_detail = img_detail
        self.video = video
        self.video_detail = video_detail
        self.b_id = b_id
        self.share_url = share_url
        self.facebook_name = facebook_name
    }
}

struct imageObject: Mappable {
    var image: String?
    var image_detail: String?
    var image_order: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        image <- map["beacon_img"]
        image_detail <- map["beacon_img_detail"]
        image_order <- map["beacon_img_order"]
    }
}

struct videoObejct: Mappable {
    var video: String?
    var video_detail: String?
    var video_order: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        video <- map["beacon_video"]
        video_detail <- map["beacon_video_detail"]
        video_order <- map["beacon_video_order"]
    }
}
