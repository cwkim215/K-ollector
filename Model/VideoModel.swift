//
//  VideoModel.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/30.
//

import Foundation
import UIKit

// Video Model that holds all the videos from the youtube api

class VideoModel {
    static let sharedVideoModel = VideoModel() // singleton
    let API_KEY: String
    let PLAYLIST_ID: String
    let API_URL: String
    var videos: [Video] = []
    let sharedData = SharedData.sharedData
    init() {
        API_KEY = ""
        PLAYLIST_ID = "PLh1BXh5214fBZ02suI-X0uFQxpPMgOPTY"
        API_URL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(PLAYLIST_ID)&key=\(API_KEY)"
        self.getVideos()
    }
    
    // initializes videos by making the request to get a K-pop youtube playlist
    func getVideos() {
        let url = URL(string: API_URL)
        var request = URLRequest(url: url!)
        var moreVids = true
        
        // semaphore because we need to make multiple requests (youtube only brings back 50 videos per request). need to wait for the first request to finish loading in before bringing in the next one.
        let semaphore = DispatchSemaphore(value: 1)
        while(moreVids) {
            semaphore.wait()
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                if data == nil {
                    return
                }
                // receives in the form of a JSON object
                let decoder = JSONDecoder()
                do {
                    let playlist = try decoder.decode(Playlist.self, from: data!)
                    if !playlist.items.isEmpty {
                        self.videos += playlist.items
                        print(self.videos.count)
                    }
                    if (playlist.nextPageToken != nil) {
                        let nextAPIURL = self.API_URL+"&pageToken=\(playlist.nextPageToken!)"
                        let nextURL = URL(string: nextAPIURL)
                        request = URLRequest(url: nextURL!)
                    }
                    else {
                        moreVids = false
                    }
                }
                catch {
                    exit(1)
                }
                semaphore.signal()
            }.resume()

        }
    }
    
    // gets a random video from the playlist and returns it
    func getRandomVideo() -> Video? {
        if (!videos.isEmpty) {
            var random = Int.random(in: 0...videos.count-1)
            while(videos[random].videoTitle == "Private video" || videos[random].videoTitle == "Deleted Video") {
                random = Int.random(in: 0...videos.count-1)
            }
            return videos[random]
        }
        else {
            return nil
        }
    }
    
    // gets the total videos loaded into the playlist
    func getTotalVideoPoolCount() -> Int {
        return videos.count
    }
}
