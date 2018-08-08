//
//  SectionTVCell.swift
//  TabWebDemo
//
//  Created by 曾政桦 on 2018/8/7.
//  Copyright © 2018年 隐贞. All rights reserved.
//

import UIKit

class SectionTVCell: UITableViewCell {
    
    static let cellID = "SectionTVCellID"

    @IBOutlet weak var sectionNameLabel: UILabel!

}

extension SectionTVCell {
    
    func loadModel(title: String) {
        sectionNameLabel.text = title
    }
}
