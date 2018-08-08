//
//  WebTVCell.swift
//  TabWebDemo
//
//  Created by 曾政桦 on 2018/8/7.
//  Copyright © 2018年 隐贞. All rights reserved.
//

import UIKit
import WebKit

class WebTVCell: UITableViewCell {
    
    static let cellID = "WebTVCellID"
    
    fileprivate var htmlHash = 0
    
    fileprivate var heightAction: ((CGFloat)->Void)?
    
    fileprivate lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let web    = WKWebView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 100), configuration: config)
        web.navigationDelegate = self
        web.scrollView.isScrollEnabled = false
        web.translatesAutoresizingMaskIntoConstraints = false
        return web
    }()
}

extension WebTVCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { (heightValue, error) in
            guard let height = heightValue as? CGFloat else { return }
            print("Web Height: \(height)")
            self.heightAction?(height)
        }
    }
}

extension WebTVCell {
    
    func loadHtml(_ text: String, heightAction: @escaping (CGFloat)->Void) {
        let textHash = text.hashValue
        guard textHash != htmlHash else { return }
        
        webView.loadHTMLString(text, baseURL: nil)
        self.heightAction = heightAction
        htmlHash = textHash
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(webView)
        
        let vfDict = ["wv": webView]
        
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[wv]|", options: [], metrics: nil, views: vfDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[wv]|", options: [], metrics: nil, views: vfDict))
    }
}
