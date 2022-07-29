//
//  Playlist.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/30.
//

import Foundation

// struct to get the full object from the JSON file
struct Playlist: Decodable {
    var items: [Video] = []
    let nextPageToken: String?
    
    enum CodingKeys:String, CodingKey {
        case items
        case nextPageToken
    }
    
    init (from decoder: Decoder) throws {
        // main container of the object
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // get the items object inside the main object to get the videos
        self.items = try container.decode([Video].self, forKey: .items)
        // if there is a next page set it, otherwise make it nil so the program knows not to try and access more videos
        do {
            self.nextPageToken = try container.decode(String.self, forKey: .nextPageToken)
        }
        catch {
            self.nextPageToken = nil
        }
    }
}
