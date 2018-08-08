//
//  HomeView.swift
//  TabWebDemo
//
//  Created by 曾政桦 on 2018/8/8.
//  Copyright © 2018年 隐贞. All rights reserved.
//

import UIKit

class HomeView: UIView {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var toolView: UIView!
    
}

extension HomeView {
    @IBAction func backBtnClick(_ sender: UIButton) {
    }
    
    @IBAction func commentBtnClick(_ sender: UIButton) {
    }
    
    @IBAction func pariseBtnClick(_ sender: UIButton) {
    }
    
    @IBAction func shareBtnClick(_ sender: UIButton) {
    }
    
    @IBAction func moreBtnClick(_ sender: UIButton) {
    }
}
