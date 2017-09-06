//
//  hotVideoTableViewCell.swift
//  vidMe
//
//  Created by Jenya on 27.08.17.
//  Copyright © 2017 Jenya. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class hotVideoTableViewCell: UITableViewCell {
   
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    
    var avPlayerViewConroller: AVPlayerViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    var videoPlayerUrl: URL? {
        didSet {
            initNewPlayerItem()
        }
    }
    
    func setupMoviePlayer() {

        // Create a new AVPlayer and AVPlayerLayer
        avPlayer = AVPlayer(url: videoPlayerUrl!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        
        // We want video controls so we need an AVPlayerViewController
        avPlayerViewConroller = AVPlayerViewController()
        avPlayerViewConroller?.player = avPlayer
        
        // Insert the player into the cell view hierarchy and setup autolayout
        avPlayerViewConroller!.view.translatesAutoresizingMaskIntoConstraints = false
        
        insertSubview(avPlayerViewConroller!.view, at: 2)
        
        avPlayerViewConroller!.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        avPlayerViewConroller!.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        avPlayerViewConroller!.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        avPlayerViewConroller!.view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        self.indicator.stopAnimating()
    }
    
    private func initNewPlayerItem() {
        indicator.isHidden = true
        indicator.startAnimating()
        
        if videoPlayerUrl != nil {
            let videoAsset =  AVAsset(url: (videoPlayerUrl)!)
            videoAsset.cancelLoading()

            let videoPlayerItem = AVPlayerItem(asset: videoAsset)

            avPlayerViewConroller?.player?.replaceCurrentItem(with: videoPlayerItem)
            videoAsset.loadValuesAsynchronously(forKeys: ["duration"]) {
                guard videoAsset.statusOfValue(forKey: "duration", error: nil) == .loaded else {
                    return
                }
                let videoPlayerItem = AVPlayerItem(asset: videoAsset)
                DispatchQueue.main.async {
                    self.avPlayerViewConroller?.player?.replaceCurrentItem(with: videoPlayerItem)
                }
            }
        }
    }
}



