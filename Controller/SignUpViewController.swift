//
//  SignUpViewController.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/29.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var messageTextField: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let sharedData = SharedData.sharedData
    
    /* Setting error label to display nothing for now, and making the max birthdate today's date. Also setting the text fields' delegate to this view controller so it can dismiss the keyboard when necessary*/
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.text = ""
        datePicker.maximumDate = Date()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPassTextField.delegate = self
        emailTextField.textContentType = .oneTimeCode
        passwordTextField.textContentType = .oneTimeCode
        confirmPassTextField.textContentType = .oneTimeCode
    }
    
    // hiding the loading indicator and have no error text when the view appears
    override func viewWillAppear(_ animated: Bool) {
        loadingIndicator.isHidden = true
        errorLabel.text = ""
    }
    
    // stop the loading indicator after the view leaves the scene
    override func viewWillDisappear(_ animated: Bool) {
        loadingIndicator.stopAnimating()
    }
    
    // delegation: set and resign first responders to make the keyboard dismiss or reappear
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
            confirmPassTextField.becomeFirstResponder()
        }
        else {
            confirmPassTextField.resignFirstResponder()
        }
        return true
    }
    
    
    // dismisses keyboard when background is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if emailTextField.isFirstResponder && touch?.view != emailTextField {
            emailTextField.resignFirstResponder()
        }
        else if passwordTextField.isFirstResponder && touch?.view != emailTextField{
            passwordTextField.resignFirstResponder()
        }
        else if confirmPassTextField.isFirstResponder && touch?.view != confirmPassTextField {
            confirmPassTextField.resignFirstResponder()
        }
    }
    
    /* creates the user identity in firebase if all textfields have valid inputs and the user is 15 years or older. */
    @IBAction func signUpDidTapped(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmed = confirmPassTextField.text!
        
        if email.isEmpty || password.isEmpty || confirmed.isEmpty {
            errorLabel.text = "Please enter all fields!"
            return
        }
        else if password != confirmed {
            errorLabel.text = "Passwords do not match!"
            return
        }
        
        else {
            let date = self.datePicker.date
            if sharedData.getDate15YearsAgo() != nil {
                if date > sharedData.getDate15YearsAgo()! {
                    errorLabel.text = "Must be 15 years or older."
                    return
                }
            }
        }
        
        // starting loading indicator to show user that login/signup process has begun
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        errorLabel.text = "Loading..."
        
        // creates user in Firebase auth
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print(error)
                self?.errorLabel.text = error.localizedDescription
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                return
            }
            
            // creating the user's username as only the portion before the email "@" sign
            var currentIndex = 0
            var i = email.index(email.startIndex, offsetBy: currentIndex)
            var username = ""
            while email[i] != "@" {
                username = username + String(email[i])
                currentIndex += 1
                i = email.index(email.startIndex, offsetBy: currentIndex)
            }
            
            // sign user up with empty video collection for now stored into Firestore
            let empty: [[String : String]] = []
            self?.sharedData.setEmail(email: email)
            self?.sharedData.user_db.collection("users").document(email).setData([
                "username": username,
                "videos": empty,
                "rollsUsed": 0,
                "rollsRemaining": 5,
                "videosWatched": 0
            ]) { err in
                if let err = err {
                    print("Error: \(err)")
                    return
                }

                // now telling the user model to begin populating its data and segue to the main roll view controller
                UserModel.sharedUserModel.setUsernameAndVideos()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self?.performSegue(withIdentifier: "signUpToMain", sender: nil)
                }
            }
            
        }
    
    }
    

}
