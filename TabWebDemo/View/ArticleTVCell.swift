//
//  ArticleTVCell.swift
//  TabWebDemo
//
//  Created by 曾政桦 on 2018/8/7.
//  Copyright © 2018年 隐贞. All rights reserved.
//

import UIKit

class ArticleTVCell: UITableViewCell {
    
    static let cellID = "ArticleTVCellID"

    @IBOutlet weak var articleImgView: UIImageView!
    
    @IBOutlet weak var articleTitleLabel: UILabel!
    
}

extension ArticleTVCell {
    
    func loadModel(_ model: ArticleModel) {
        articleImgView.image    = UIImage(named: model.img)
        articleTitleLabel.text  = model.title
    }
}
