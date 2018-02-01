//
//  CommentData.swift
//  Instagram
//
//  Created by 出島大和 on 2018/01/30.
//  Copyright © 2018年 出島大和. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CommentData: NSObject {
    var id: String?
    var name: String?
    var date: Date?
    var comment:String?
    
    init(valueDictionary: Dictionary<String, Any>, key: String) {
        self.id = key
        
        self.name = valueDictionary["name"] as? String
        
        self.comment = valueDictionary["comment"] as? String
        
        let time = valueDictionary["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)

    }
    

}
