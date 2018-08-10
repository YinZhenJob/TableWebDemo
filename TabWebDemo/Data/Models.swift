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
    
    let content: String
}


extension ArticleModel {
    
    static func `default`() -> ArticleModel {
        return ArticleModel(title: "《人间失格》",
                            img: "01",
                            content: htmlMake(content: html_01))
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
    
    var data: AnyObject
    
    var height: CGFloat?
    
    init(type: CellE, data: AnyObject, height: CGFloat? = nil) {
        self.type = type
        self.data = data
        self.height = height
    }
}

