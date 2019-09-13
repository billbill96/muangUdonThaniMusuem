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
    var img: String?
    var img_detail: String?
    var img_order: Int?
    var video: String?
    var video_detail: String?
    var video_order: Int?
    var b_id: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        u_id <- map["u_id"]
        notify <- map["beacon_notify"]
        topic <- map["beacon_topic"]
        img <- map["beacon_img"]
        img_detail <- map["beacon_img_detail"]
        img_order <- map["beacon_img_order"]
        video <- map["beacon_video"]
        video_detail <- map["beacon_video_detail"]
        video_order <- map["beacon_video_order"]
        b_id <- map["b_id"]
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
    var b_id: String
    
    init(u_id: String, notify: String, topic: String, img: [String], img_detail: [String], video: [String], video_detail: [String], b_id: String) {
        self.u_id = u_id
        self.notify = notify
        self.topic = topic
        self.img = img
        self.img_detail = img_detail
        self.video = video
        self.video_detail = video_detail
        self.b_id = b_id
    }
}
