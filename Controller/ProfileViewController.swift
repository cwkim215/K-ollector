//
//  ProfileViewController.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/29.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var videosWatchedLabel: UILabel!
    @IBOutlet weak var totalRolls: UILabel!
    @IBOutlet weak var totalVideosLeft: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    
    let videoModel = VideoModel.sharedVideoModel
    let sharedData = SharedData.sharedData
    let userModel = UserModel.sharedUserModel
    let storage = Storage.storage().reference()
    // boolean to see whether or not a user has set their own profile image
    var profileImgSet = true
    
    // loading user profile image as a base one for the time being
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImg.image = UIImage(named: "user")

    }
    
    // setting all of the users information for display based on the user model
    override func viewWillAppear(_ animated: Bool) {
        profileNameLabel.text = userModel.getUsername()
        let currentVideoCount = userModel.getTotalUserVideoCount()
        totalCountLabel.text = "Current Video Count: \(currentVideoCount)"
        videosWatchedLabel.text = "Videos to watch before reset:  \(3 - userModel.getVideosWatched())"
        totalRolls.text = "Rolls used: \(userModel.getTotalRollsUsed())"
        totalVideosLeft.text = "Total Videos Left: \(videoModel.getTotalVideoPoolCount() - userModel.getTotalUserVideoCount())"
        
        // load image onlt if the user has set it (always check the first time)
        if profileImgSet == true {
            setProfileImage()
        }
    }
    
    // button that allows user to edit their profile image through the image picker
    @IBAction func editImageDidTapped(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickerController.sourceType = .camera
        }
        else {
            pickerController.sourceType = .photoLibrary
        }
        
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    // selects the users choice for photo and both sets the image and uploads it to Firebase storage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image: UIImage = info[.editedImage] as? UIImage else { return }
        profileImg.image = image
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        sharedData.addImage(url: userModel.getFixedUsername(), data: data)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let childString = sharedData.image_storage + userModel.getFixedUsername() + ".jpg"
        storage.child(childString).putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // checks Firebase storage to see if the user had previously uploaded an image as their profile
    func setProfileImage() {
        // first check to see if the image has already been set, then we should just grab the data from our shared data model
        if sharedData.getImage(url: userModel.getFixedUsername()) != nil {
            let data = sharedData.getImage(url: userModel.getFixedUsername())
            let profile = UIImage(data: data!)
            DispatchQueue.main.async {
                self.profileImg.image = profile
            }
            
        }
        // otherwise get it from Firebase storage and save it
        else {
            let downloadStorage = Storage.storage().reference(withPath: sharedData.getImageStorageFolder() + userModel.getFixedUsername() + ".jpg")
            downloadStorage.getData(maxSize: (1*1024*1024)) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    // if not then the app should not check for it again
                    self.profileImgSet = false
                    return
                }
                if let data = data {
                    let profile = UIImage(data: data)
                    self.sharedData.addImage(url: self.userModel.fixedUsername, data: data)
                    DispatchQueue.main.async {
                        self.profileImg.image = profile
                    }
                }
            }
        }
    }
    
    // allows user to sign out of the app
    @IBAction func signOutDidTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            profileNameLabel.text = "Signing out..."
            performSegue(withIdentifier: "signOut", sender: nil)
        }
        catch let signOutError as NSError {
            print(signOutError)
        }
    }
    
}
