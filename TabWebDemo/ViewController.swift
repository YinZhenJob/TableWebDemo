//
//  ViewController.swift
//  TabWebDemo
//
//  Created by 曾政桦 on 2018/8/7.
//  Copyright © 2018年 隐贞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate lazy var modelList: [CellModel] = {
        let model1 = CellModel(type: .web, data: htmlMake(content: html_01) as AnyObject)
        let model2 = CellModel(type: .section, data: "推荐阅读" as AnyObject)
        let model3 = CellModel(type: .article, data: ArticleModel.default() as AnyObject)
        return [model1, model2, model3]
    }()

    @IBOutlet var containView: HomeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "《人间失格》- 节选"
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = modelList[indexPath.row]
        if model.type == .web {
            return model.height ?? 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = modelList[indexPath.row]
        switch model.type {
        case .web:
            let cell = tableView.dequeueReusableCell(withIdentifier: WebTVCell.cellID, for: indexPath) as! WebTVCell
            cell.loadHtml(model.data as! String) { webHeight in
                model.height = webHeight
                tableView.reloadData()
            }
            return cell
            
        case .article:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTVCell.cellID, for: indexPath) as! ArticleTVCell
            cell.loadModel(model.data as! ArticleModel)
            return cell
            
        case .section:
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionTVCell.cellID, for: indexPath) as! SectionTVCell
            cell.loadModel(title: model.data as! String)
            return cell
        }
    }
}
