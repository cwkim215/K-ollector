//
//  Video.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/30.
//

import Foundation

// holds the Video object
struct Video : Decodable {
    let videoId: String
    let videoTitle: String
    let description: String
    let thumbnail: String
    var date: String
    
    var dict: [String : String] = [:]
    
    //specifying the keys that need to be accessed from the JSON
    enum CodingKeys: String, CodingKey {
        case snippet
        case thumbnails
        case high
        case published = "publishedAt"
        case title
        case description
        case thumbnail = "url"
        case resourceId
        case videoId
    }
    
    init(from decoder: Decoder) throws {
        // container of full object
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // container for object holding relevant information inside the main container
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        
        self.videoTitle = try snippetContainer.decode(String.self, forKey: .title)
        // if the video is not accessible anymore just put no values in
        if videoTitle == "Private video" || videoTitle == "Deleted video"{
            description = ""
            date = ""
            thumbnail = ""
            videoId = ""
        }
        else {
            self.description = try snippetContainer.decode(String.self, forKey: .description)
            
            self.date = try snippetContainer.decode(String.self, forKey: .published)
            var dateFixed = ""
            var currentIndex = 0
            var i = date.index(date.startIndex, offsetBy: currentIndex)
            while currentIndex < 10 {
                dateFixed = dateFixed + String(date[i])
                currentIndex += 1
                i = date.index(date.startIndex, offsetBy: currentIndex)
            }
            date = dateFixed
            
            //need another nested container for the thumbnail object itself
            let thumbnailCont = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
            //want the high thumbnail object
            let highThumbnailCont = try thumbnailCont.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
            self.thumbnail = try highThumbnailCont.decode(String.self, forKey: .thumbnail)
            
            //need the container holding the video's id
            let resourceIdCont = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .resourceId)
            self.videoId = try resourceIdCont.decode(String.self, forKey: .videoId)
        }
        
        // creating dictionary version of the video for saving to Firestore
        dict["videoId"] = self.videoId
        dict["videoTitle"] = self.videoTitle
        dict["description"] = self.description
        dict["thumbnail"] = self.thumbnail
        dict["date"] = self.date
    }
}
