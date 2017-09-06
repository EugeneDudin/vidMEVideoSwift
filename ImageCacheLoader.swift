//
//  ImageCacheLoader.swift
//  vidMe
//
//  Created by Jenya on 28.08.17.
//  Copyright © 2017 Jenya. All rights reserved.
//

import Foundation
import AVKit
//import AVFoundation


class ImageCacheLoader {
    
    typealias ImageCacheLoaderCompletionHandler = ((UIImage) -> ())
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
    }
    
    func obtainImageWithPath(imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler) {
        if let image = self.cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image)
            }
        } else {
            let placeholder = UIImage(named: "placeholder")
            DispatchQueue.main.async {
                completionHandler(placeholder!)
            }
            let url: URL! = URL(string: imagePath)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    if let imgw = UIImage(data: data) {
                        print("SAVE")
                        self.cache.setObject(imgw, forKey: imagePath as NSString)
                        DispatchQueue.main.async {
                            completionHandler(imgw)
                        }
                    }
                }
            })
            task.resume()
        }
    }
}
