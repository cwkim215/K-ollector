//
//  VideoViewController.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/05/02.
//

import UIKit
import WebKit

class VideoViewController: UIViewController {

    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var dateReleasedLabel: UILabel!
    @IBOutlet weak var videoNumberLabel: UILabel!
    
    var videoTitle: String = ""
    var releaseDate: String = ""
    var videoNumber: Int = 0
    var videoId: String = ""
    var ytLink = "https://www.youtube.com/watch?v="
    let userModel = UserModel.sharedUserModel
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // sets the web view to be the youtube video and gives the video name, release date, and number in the user's collection
    override func viewWillAppear(_ animated: Bool) {
        videoTitleLabel.text = videoTitle
        dateReleasedLabel.text = releaseDate
        videoNumberLabel.text = "Collection #: \(videoNumber)"
        
        let url = URL(string: ytLink + videoId)
        let request = URLRequest(url: url!)
        videoWebView.load(request)
        
        if userModel.getVideosWatched() == 0 {
            let alertController = UIAlertController(title: "Congratulations!", message: "Your rolls have reset back to 5!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
