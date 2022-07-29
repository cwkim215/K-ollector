//
//  SharedData.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/05/01.
//

import Foundation
import Firebase

// Shared Data that can be used to improve accessing data from requests
class SharedData {
    static let sharedData = SharedData()
    var email: String
    var username: String
    // user Firestore
    let user_db = Firestore.firestore()
    let image_storage = "profiles/"
    // HOLDS IMAGE DATA SO DON'T NEED TO CONTINIOUSLY MAKE URL REQUESTS
    var images = [String:Data]()
    let date15yearsAgo: Date?
    init() {
        email = ""
        username = ""
        // initialized to make sure user is above the age of 15
        date15yearsAgo = Calendar.current.date(byAdding: .year, value: -15, to: Date())
    }
    
    func setEmail(email email_:String) {
        email = email_
    }
    
    func addImage(url:String, data:Data?) {
        images[url] = data
    }
    
    func getImage(url:String) -> Data? {
        return images[url]
    }
    
    func getImageStorageFolder() -> String {
        return image_storage
    }
    
    func getDate15YearsAgo() -> Date? {
        return date15yearsAgo
    }
}
