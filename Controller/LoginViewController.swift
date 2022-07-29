//
//  LoginViewController.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/04/29.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let sharedData = SharedData.sharedData
    
    // setting the text fields' delegates to be this view controller to handle dismissing the keyboard
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.textContentType = .oneTimeCode
        passwordTextField.textContentType = .oneTimeCode
        definesPresentationContext = true
    }
    
    // hiding the loading indicator and have no error text when the view appears
    override func viewWillAppear(_ animated: Bool) {
        loadingIndicator.isHidden = true
        errorLabel.text = ""
        emailTextField.becomeFirstResponder()
    }
    
    // stopping the loading indicator after the view is disappearing
    override func viewWillDisappear(_ animated: Bool) {
        loadingIndicator.stopAnimating()
    }
    
    // delegation: set and resign first responders to make the keyboard dismiss or reappear
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        else {
            passwordTextField.resignFirstResponder()
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
    }
    
    /* signs user in if they have a valid email and password entered in the text fields */
    @IBAction func loginButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            errorLabel.text = "Please enter email and password!"
            return
        }
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        errorLabel.text = "Loading..."
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorLabel.text = error.localizedDescription
                print(error)
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                return
            }
            
            // setting the email in the shared data model
            self?.sharedData.setEmail(email: email)
            //telling the user model to now populate its data since the user has signed in and performing segue to main roll view controller
            UserModel.sharedUserModel.setUsernameAndVideos()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self?.performSegue(withIdentifier: "loginToMain", sender: nil)
            }
        }
        
        
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        performSegue(withIdentifier: "signUpSegue", sender: nil)
    }
    

}
