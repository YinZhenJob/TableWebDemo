//
//  Models.swift
//  TabWebDemo
//
//  Created by 曾政桦 on 2018/8/8.
//  Copyright © 2018年 隐贞. All rights reserved.
//

import UIKit

/* - - -  - - - Article - --  - - - - - - */
struct ArticleModel {

    let title: String
    
    let img: String
}


extension ArticleModel {
    
    static func `default`() -> ArticleModel {
        return ArticleModel(title: "他不相信上帝的恩宠，只相信上帝的惩罚",
                            img: "fireSpace")
    }
}

/* - - -  - - - Cell - --  - - - - - - */
enum CellE {
    case web
    case article
    case section
}

class CellModel {
    
    let type: CellE
    
    let data: AnyObject
    
    var height: CGFloat?
    
    init(type: CellE, data: AnyObject, height: CGFloat? = nil) {
        self.type = type
        self.data = data
        self.height = height
    }
}

