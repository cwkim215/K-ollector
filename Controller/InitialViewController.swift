//
//  InitialViewController.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/05/03.
//

import UIKit
import Firebase

class InitialViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let sharedData = SharedData.sharedData
    
    // either segue user to the main screen if they are logged in or to the login page if they are not.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadingIndicator.startAnimating()
        
        Auth.auth().addStateDidChangeListener() { [weak self] auth, user in
            
            if user == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self?.performSegue(withIdentifier: "initialToLogin", sender: nil)
                }
            }
            else {
                self?.sharedData.setEmail(email: (user?.email)!)
                UserModel.sharedUserModel.setUsernameAndVideos()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self?.performSegue(withIdentifier: "initialToMain", sender: nil)
                }
            }
        }
    }
    
    
    // stops loading indicator once the user is sent to a different view
    override func viewWillDisappear(_ animated: Bool) {
        loadingIndicator.stopAnimating()
    }

}
