//
//  model.swift
//  vidMe
//
//  Created by Jenya on 18.08.17.
//  Copyright © 2017 Jenya. All rights reserved.
//

import UIKit

struct videoModel {
    
    enum video: String {
        case title, countView, countLike, videoImage
    }
    
    var videoTitle: String
    var videoURL: String!
    var countView: Int
    var countLike: Int
    var videoImage: String
}

extension videoModel {
    
    init?(JSON: Any) {
        
        guard let json = JSON as? [String: AnyObject] else { return nil }
        self.videoTitle = json["title"] as! String
        guard let url = json["complete_url"] as? String else { print("complete_url error"); return nil }
        
        self.videoURL = url
        self.countView = json["view_count"] as! Int
        self.countLike = json["score"] as! Int
        // self.videoDiscription = json["description"] as! String
        self.videoImage = json["thumbnail_url"] as! String
    }
}

let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
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
                print(error!)
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



