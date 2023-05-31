//
//  ViewController.swift
//  Project28
//
//  Created by Brandon Johns on 5/31/23.
//

import UIKit
import LocalAuthentication


class ViewController: UIViewController
{
    
    @IBOutlet var secret: UITextView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default                                                                     //watch for keyboard
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil) //keyboard changes or hides let us know
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        
        
    }//viewDidLoad
    
    @objc func adjustForKeyboard(notification: Notification)
    {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }     //NSValues wraps CGRect
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue                                                                    // size of keyboard relative to the screen
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)                                         // keyboard based on rotation
        
        if notification.name == UIResponder.keyboardWillHideNotification                                                            //keyboard hidding or nto
        {
            secret.contentInset = .zero                                                                                             //set secret (TextUI) to fullscreen
        }//if
        
        else
        {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            //keyboard in view
        }//else
        
        secret.scrollIndicatorInsets = secret.contentInset                                                                      //size of the scroll bar
        //size of tool bar
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)                                                                              // whats viewable
        
    }//adjustForKeyboard
    
    
    @IBAction func authenticateTapped(_ sender: Any)
    {
        let context = LAContext()                                       //LAContext local authenication
        
        var error: NSError?                                             // objc form of error
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"                                                                   //only touchID
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            { [weak self] success, authenticationError in
                
                DispatchQueue.main.async
                {
                    if success
                    {
                        self?.unlockSecretMessage()
                    }//success
                    
                    else
                    {
                        let alert_controller = UIAlertController(title: "Authentication Error", message: "You could not be verified please try again", preferredStyle: .alert)
                        alert_controller.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert_controller, animated:  true)
                    }//else
                    
                }//DispatchQueue
                
            }//closure
            
        }//if context.canEval
        
        else
        {
            let alert_controller = UIAlertController(title: "Biometry unavalible", message: "your device cannot handle biometric authenication", preferredStyle: .alert)
            alert_controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_controller, animated:  true)
            
        }//else
        
    }//authenticateTapped



func unlockSecretMessage()
{
    secret.isHidden = false
    title = "Secret Stuff"
    
    secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    
    
}//unlockSecretMessage

@objc func saveSecretMessage()
{
    guard secret.isHidden == false else {return}
    
    KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
    
    secret.resignFirstResponder()
    
    secret.isHidden = true
    
    title = "Nothing to see here"
    
}//saveSecretMessage

}//ViewController

