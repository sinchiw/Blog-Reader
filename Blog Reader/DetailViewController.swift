//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Wilmer sinchi on 1/16/19.
//  Copyright © 2019 Wilmer sinchi. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        
        if let detail = detailItem {
            self.title = detail.value(forKey: "title") as? String
            if let blogWebView = self.webView {
                blogWebView.loadHTMLString((detail.value(forKey: "content") as? String)!, baseURL: nil)
                // almost all of the link, absolute links, (https ), you dont need the bsae url
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

