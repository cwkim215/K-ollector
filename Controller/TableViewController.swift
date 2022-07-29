//
//  TableViewController.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/30.
//

import UIKit

class TableViewController: UITableViewController, UserModelDelegate {
    
    // fucntions that conform the the UserModelDelegate protocol
    
    // reloading the data once the user's video collection has been updated
    func videosUpdated() {
        tableView.reloadData()
    }
    
    let videoModel = VideoModel.sharedVideoModel
    let userModel = UserModel.sharedUserModel
    let sharedModel = SharedData.sharedData
    
    // setting the table view as the user model's delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        userModel.delegate = self
    }
    
    // total rows = # of videos in user collection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userModel.getTotalUserVideoCount()
    }
    
    // setting height of cell to be 150
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    // setting the cell to contain the name of video and video thumbnail
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! TableViewCell
        
        // start from most recent video to first video
        let video = userModel.getUserVideoAtIndex(index: userModel.getTotalUserVideoCount() - 1 - indexPath.row)
        
        let vidTitle = video["videoTitle"]
        let vidThumbnail = video["thumbnail"]
        if vidTitle != nil && vidThumbnail != nil {
            cell.setVideo(title: vidTitle!, thumbnail: vidThumbnail!)
        }
        return cell
    }
    
    // if a row is selected, send the user to the view where they can watch the video
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "tableToWeb", sender: nil)
        }
    }
    
    // sets the data needed for the view with the video
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let video = userModel.getUserVideoAtIndex(index: userModel.getTotalUserVideoCount() - 1 - tableView.indexPathForSelectedRow!.row)
        
        let videoViewController = segue.destination as! VideoViewController
        
        videoViewController.videoTitle = video["videoTitle"] ?? ""
        videoViewController.releaseDate = video["date"] ?? ""
        videoViewController.videoNumber = userModel.getTotalUserVideoCount() - tableView.indexPathForSelectedRow!.row 
        videoViewController.videoId = video["videoId"] ?? ""
        self.userModel.videoWatched()
    }
}
