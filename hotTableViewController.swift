//
//  hotTableViewController.swift
//  vidMe
//
//  Created by Jenya on 20.08.17.
//  Copyright © 2017 Jenya. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class hotTableViewController: UITableViewController {
    
    var hotVideoData = [videoModel]()
    let dataManager = DataManagere()
    let imageLoader = ImageCacheLoader()
    
    // MARK: - config
    var limit = 3
    var offset = 0
    
    var ind = IndexPath()
    var play = false

    // MARK: - Add Property
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .bottom
        self.automaticallyAdjustsScrollViewInsets = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        // tableView.contentInset.top = 10
        // tableView.scrollIndicatorInsets.bottom = 10
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        fetchVideoData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func deviceOrientationDidChange() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            print("landscapeLeft")
            // playerLayer = AVPlayerLayer.animation(playerLayer)
           //  playerLayer.frame = UIScreen.main.bounds
            print(UIScreen.main.bounds)
            print(self.view.bounds)
            tableView.isScrollEnabled = false
            
        default:
            print("minToFrame")
            tableView.isScrollEnabled = true
            }
    }
    
    func setupView() {
        setupTableView()
    }
    
    func setupTableView() {
        self.view.tintColor = .white
        info.text = "Connecting..."
        self.view.addSubview(activityIndicator)
    }
    
    private func fetchVideoData() {
        self.activityIndicator.startAnimating()
        self.dataManager.getVideo(url: "https://api.vid.me/videos/hot?offset=\(addOffset())&limit=\(limit)") { (data, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.info.text = "error..." // 
                }
                if let video = data {
                    self.hotVideoData.append(video)
                    
                    self.updateView()
                }
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func addOffset() -> Int {
        offset += 3
        return offset
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return hotVideoData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> hotVideoTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hot") as! hotVideoTableViewCell
        
        // Configure the cell...
        let index = indexPath.row
       
        cell.title.text = hotVideoData[index].videoTitle
        imageLoader.obtainImageWithPath(imagePath: hotVideoData[index].videoImage) { (image) in
            
            cell.indicator.isHidden = false
            cell.indicator.startAnimating()
            // Before assigning the image, check whether the current cell is visible
            guard let updateCells = tableView.cellForRow(at: indexPath) as! hotVideoTableViewCell! else {
                return
            }
            updateCells.videoImage?.image = image
            updateCells.videoImage.alpha = 1
            cell.indicator.isHidden = true
        }
        cell.avPlayerViewConroller?.player?.pause()
        cell.avPlayerViewConroller?.view.removeFromSuperview()
        cell.indicator.stopAnimating()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ind != indexPath {
            if play {
                removePlayer(index: ind)
            }
                self.addPlayer(index: indexPath)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            print(">>>updateView")
            fetchVideoData()
        }
    }
    
    func addPlayer(index: IndexPath) {
        guard let cell = tableView.cellForRow(at: index) as! hotVideoTableViewCell! else {
            return
        }
        cell.videoImage.alpha = 0.5
        
        DispatchQueue.main.async {
            if let videoURL = URL(string: self.hotVideoData[index.row].videoURL) {
                cell.videoPlayerUrl = videoURL
                cell.setupMoviePlayer()
            }
        cell.avPlayerViewConroller?.player?.play()
        }
        ind = index
        play = true
    }
    
    func removePlayer(index: IndexPath) {
        guard let updateCells = tableView.cellForRow(at: index) as! hotVideoTableViewCell! else {
            return
        }
        updateCells.videoImage.alpha = 1
        DispatchQueue.main.async {
            updateCells.avPlayerLayer?.backgroundColor = UIColor.blue.cgColor
            updateCells.avPlayerViewConroller?.player?.pause()
            updateCells.avPlayerViewConroller?.player?.seek(to: CMTimeMake(0,1))
            updateCells.avPlayerViewConroller?.view.removeFromSuperview()
        }
    }
    
    func updateView() {
        self.tableView.reloadData()
    }
}
