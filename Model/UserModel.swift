//
//  UserModel.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/30.
//

import Foundation
import Firebase

// Delegation to update the table view
protocol UserModelDelegate {
    func videosUpdated()
}

// User Model that holds all relevant information in regards to the user
class UserModel {
    static let sharedUserModel = UserModel() // singleton
    var username: String
    var fixedUsername: String
    var currentVideos: [[String : String]] // the user's video collection
    var rollsUsed: Int // the total rolls they've used since registering
    var rollsRemaining: Int // the rolls they have left before they need to do a reset by watching videos
    var videosWatched: Int // the amount of videos they have watched so far (need a total of 3 to reset the rolls)
    let sharedData = SharedData.sharedData
    let videoModel = VideoModel.sharedVideoModel
    var delegate: UserModelDelegate?
    init() {
        username = ""
        fixedUsername = ""
        currentVideos = []
        rollsUsed = 0
        rollsRemaining = 0
        videosWatched = 0
    }
    // called once a user logs into the app
    func setUsernameAndVideos() {
        // grabs all the data from firestore
        sharedData.user_db.collection("users").document(sharedData.email).getDocument { snap, err in
            if let err = err {
                print("Error: \(err.localizedDescription)")
                return
            }
            if let data = snap?.data(){
                self.username = data["username"] as! String
                self.fixedUsername = self.username.replacingOccurrences(of: ".", with: "")
                self.currentVideos = data["videos"] as! [[String : String]]
                self.rollsUsed = data["rollsUsed"] as! Int
                self.rollsRemaining = data["rollsRemaining"] as! Int
                self.videosWatched = data["videosWatched"] as! Int
                self.delegate?.videosUpdated() // telling the delegate the the user's collection has been changed
                
                if self.videosWatched >= 3 {
                    self.videosWatched = 0
                    self.rollsRemaining = 5
                }
            }
        }
    }
    
    // adds a video to the user's collection and appends the document in Firestore
    func addVideo(video:Video) {
        currentVideos.append(video.dict)
        delegate?.videosUpdated()
        sharedData.user_db.collection("users").document(sharedData.email).setData([
            "username" : username,
            "videos" : currentVideos,
            "rollsUsed": rollsUsed,
            "rollsRemaining": rollsRemaining,
            "videosWatched": videosWatched]) { err in
            if let err = err {
                print("Error: \(err)")
            }
        }
        
        
    }
    
    // checks whether or not the user has already gotten this video before
    func checkDuplicate(video:Video)-> Bool{
        for vid in currentVideos {
            if vid["videoTitle"] == video.videoTitle {
                return true
            }
        }
        rollsUsed += 1 // checks everytime a user rolls so we update rolls here
        return false
    }
    
    // updates if the user has watched a video via their collection
    func videoWatched() {
        videosWatched += 1
        
        // a user has 5 rolls total. after they use it they must watch 3 videos to get a reset on their rolls (or simply get a reset when they watch 3 even if they aren't at 0)
        if videosWatched >= 3 {
            videosWatched = 0
            rollsRemaining = 5
        }
        // updates firestore
        sharedData.user_db.collection("users").document(sharedData.email).setData([
            "username" : username,
            "videos" : currentVideos,
            "rollsUsed": rollsUsed,
            "rollsRemaining": rollsRemaining,
            "videosWatched": videosWatched]) { err in
            if let err = err {
                print("Error: \(err)")
            }
        }
    }
    
    // getters for user model data
    func getUsername()->String {
        return username
    }
    
    func getFixedUsername()->String {
        return fixedUsername
    }
    
    func getTotalRollsUsed() -> Int {
        return rollsUsed
    }
    
    func getRollsRemaining() -> Int {
        return rollsRemaining
    }
    
    func getVideosWatched() -> Int {
        return videosWatched
    }
    
    func getTotalUserVideoCount() -> Int {
        return currentVideos.count
    }
    
    func getUserVideoAtIndex(index:Int) -> [String : String] {
        return currentVideos[index]
    }
    
    // decrements users roll
    func rolledOnce() {
        rollsRemaining -= 1
    }
}
