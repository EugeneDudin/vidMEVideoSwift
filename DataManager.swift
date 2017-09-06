//
//  DataManager.swift
//  vidMe
//
//  Created by Jenya on 18.08.17.
//  Copyright © 2017 Jenya. All rights reserved.
//

import UIKit

enum DataManagerError: Error {
    case Unknown
    case FailedRequest
    case InvalidResponse
}

class DataManagere {
    
    typealias getJSON = (videoModel?, DataManagerError?) -> ()
    
    func getVideo(url: String, completion: @escaping getJSON) {
        print("getVideo")
        let url = URL(string: url)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            self.didFetchVideoData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    
    private func didFetchVideoData(data: Data?, response: URLResponse?, error: Error?, completion: @escaping getJSON) {
        print("didFetchVideoData")
        if let _ = error {
            completion(nil, .FailedRequest)
        } else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                self.extract_data(data: data, completion: completion)
            } else {
                completion(nil, .FailedRequest)
            }
        } else {
            completion(nil, .Unknown)
        }
    }
    
    func extract_data(data: Data?, completion: @escaping getJSON) {
        print("extract_data")
        
        if(data == nil) {
            print("error")
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            if let video = json["videos"] as? [[String: Any]] {
                for data in video {
                    completion(videoModel(JSON: data), nil)
                    print(data["complete_url"]!)
                }
            }
        }
        catch
        {
            return
        }
    }
}
