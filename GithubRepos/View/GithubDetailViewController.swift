//
//  GithubDetailViewController.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/5/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import UIKit

/**
 * @discussion class for the detail view controller
 */
class GithubDetailViewController: UIViewController {
    
    @IBOutlet weak var githubWebView: UIWebView!

    var webViewLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    // call the web view everytime wants to appear in screen
    override func viewWillAppear(_ animated: Bool) {
        if let _webViewLink = webViewLink {
            if let url = URL(string: _webViewLink) {
                callWebView(link: url)
            }
        }
    }
    
    /**
     * @discussion function for setup web view UI
     */
    private func setupWebView(){
        githubWebView.scrollView.bounces = false
        self.navigationController?.navigationBar.tintColor = UIColor.white        
    }
    
    /**
     * @discussion function for loading the URL
     * @param link which is the link of the URL
     */
    private func callWebView(link: URL){
        let request = URLRequest(url: link, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10.0)
        githubWebView.loadRequest(request)
    }
}
