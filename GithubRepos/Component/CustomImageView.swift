//
//  CustomImageView.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/5/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation
import UIKit

// public image cache
let imageCache = NSCache<NSString, UIImage>()

/**
 * @discussion Custom Component of Image View to caching the image before loading new Image
 */
class CustomImageView:  UIImageView {
    var imageUrlString: String?
    
    func loadImageUsingUrlString(_ urlString: String) {
        imageUrlString = urlString
        let url = URL(string: urlString)
        image = nil
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: {
                let imageToCache = UIImage(data: data!)
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            })
        }).resume()
    }
    
}
