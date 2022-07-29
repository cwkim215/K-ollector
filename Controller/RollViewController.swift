//
//  RollViewController.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/30.
//

import UIKit
import UserNotifications

class RollViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var videoModel = VideoModel.sharedVideoModel
    var userModel = UserModel.sharedUserModel
    let sharedData = SharedData.sharedData
    
    // notifications
    let userNotificationCenter = UNUserNotificationCenter.current()

    // initially sets the view to have default values
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainLabel.text = "Hello! Let's Roll..."
        artistLabel.text = "Artist:"
        dateLabel.text = "Released:"
        mainImg.image = UIImage(named: "question")
        
        if userModel.getRollsRemaining() == 0 {
            timerLabel.text = "Videos to watch until reset: \(3 - userModel.getVideosWatched())"
        }
        else {
            timerLabel.text = ""
        }
        
        // ready's the notification to be sent at 12pm everyday
        requestNotificationAuthorization()
        sendNotification()
    }
    
    // update to show the amount of videos the user has to watch before they can roll again and also how many rolls they have remaining
    override func viewWillAppear(_ animated: Bool) {
        if userModel.getRollsRemaining() == 0 {
            timerLabel.text = "Videos to watch until reset: \(3 - userModel.videosWatched)"
        }
        else {
            timerLabel.text = ""
        }
        mainLabel.text = "ROLLS REMAINING: \(userModel.getRollsRemaining())"
    }

    
    // rolls for the user by getting a random video from the main video model
    @IBAction func rollDidTapped(_ sender: UIButton) {
        if userModel.getRollsRemaining() != 0 {
            userModel.rolledOnce()
            let newVideo = videoModel.getRandomVideo()
            if newVideo != nil {
                // adds to user collection only if it hasn't been added already
                if userModel.checkDuplicate(video: newVideo!) {
                    dateLabel.text = "Duplicate..."
                }
                else {
                    userModel.addVideo(video: newVideo!)
                    dateLabel.text = newVideo!.date
                }
                // sets the UI of the screen. Grabs the thumnail through a request and adds it to the shared image data if it finds it
                artistLabel.text = newVideo!.videoTitle
                let url = URL(string: newVideo!.thumbnail)
                URLSession.shared.dataTask(with: url!) { data, response, error in
                    if let error = error {
                        print("Error IMAGE: \(error)")
                    }
                    if data != nil {
                        self.sharedData.addImage(url: newVideo!.thumbnail, data: data)
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async {
                            self.mainImg.image = image
                        }
                    }
                }.resume()
            }
        }
        // updating UI
        mainLabel.text = "ROLLS REMAINING: \(userModel.getRollsRemaining())"
        if userModel.getRollsRemaining() == 0 {
            timerLabel.text = "Videos to watch until reset: \(3 - userModel.getVideosWatched())"
        }
        else {
            timerLabel.text = ""
        }
    }
    
    // requests notification access to user if they are new
    func requestNotificationAuthorization() {
        let auth = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: auth) { (success, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    // gets ready to send notification to app users at 12pm PST everyday.
    func sendNotification() {
        let noti = UNMutableNotificationContent()
        
        noti.title = "Already gone?"
        noti.body = "Roll to discover more K-pop videos!"
        noti.badge = NSNumber(value: 1) // shows a value of 1 on badge app
        
        var time = DateComponents()
        time.hour = 12
        time.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: "mainNotification", content: noti, trigger: trigger)
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Error: \(error)")
            }
            
        }
    }
    
}
