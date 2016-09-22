//
//  STSignInController.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Firebase

class STSignInController: UIViewController {
	
	// MARK: - IBOulets
	@IBOutlet weak var emailTextField: UITextField!
	
	@IBOutlet weak var pwTextField: UITextField!
	
	@IBOutlet weak var googleSignInBtn: GIDSignInButton!

	@IBOutlet weak var signInBtn: UIButton!
	
	@IBOutlet weak var signInStackView: UIStackView!
	
	
	// MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// HideKeyboardWhenTappedAround
		hideKeyboardWhenTappedAround()
		
		// Animation
		entryAnimation()
		
		// Google Login
		GIDSignIn.sharedInstance().uiDelegate = self
		let tap = UITapGestureRecognizer(target: self, action: #selector(STSignInController.didTapGoogleSignInBtn(_:)))
		googleSignInBtn.addGestureRecognizer(tap)
		googleSignInBtn.style = .wide
	    // Uncomment to automatically sign in the user.
		// GIDSignIn.sharedInstance().signInSilently()
		
		// Notification
		STHelpers.addNotifObserver(to: self, selector: #selector(STSignInController.userLoginStatusDidChange(notification:)), name: kUserLoginStatusDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - helpers
	private func entryAnimation(){
		
		STHelpers.delay(withSeconds: 0.5){
			let originalBounds = self.signInStackView.bounds
			self.signInStackView.bounds = CGRect(x: originalBounds.origin.x, y: self.view.frame.height, width: originalBounds.width, height: -originalBounds.height)
			UIView.animate(withDuration: 1) {
				self.signInStackView.bounds = originalBounds
			}
		}
	}
	
	func signInIsValidated() -> (email: String?, pw: String?, success: Bool){
		
		if let email = emailTextField.text,
			let pw = pwTextField.text,
			email.trimmingCharacters(in: .whitespaces) != "",
			pw.trimmingCharacters(in: .whitespaces) != ""{
			
			return (email, pw, true)
		}
		
		return (nil, nil, false)
	}
	
	// MARK: - Notification
	func userLoginStatusDidChange(notification: Notification){
		
		guard let userInfo = notification.userInfo,
			let loginStatus = userInfo["loginStatus"] as? STUserLoginStatus else {
				return
		}
		
		switch loginStatus {
			
		case .loggedIn:
			
			self.dismiss(animated: true, completion: nil)
			
		case .failed(let error):

			STHelpers.showAlterView(title: "Oops", message: error.localizedDescription, actionTitle: nil, vc: self)
			
		case .loggedOff:
			
			break
			
		}
		
		MBProgressHUD.hide(for: self.view, animated: true)
	}
	
	// MARK: - user actions
	@IBAction func didTapLoginWithEmail(_ sender: UIButton) {
		
		let (email, pw, validated) = signInIsValidated()
		
		if(validated){
			
			FIRAuth.auth()?.signIn(withEmail: email!, password: pw!, completion: { (user, error) in
				
				if error != nil {
					
					FIRAuth.auth()?.createUser(withEmail: email!, password: pw!, completion: { (user, error) in
						
						if let error = error {
							STHelpers.showAlterView(title: "Oops", message: error.localizedDescription , actionTitle: "I see", vc: self)
						}else{
							STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.loggedIn])
						}
					})
					
				}else{
					STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.loggedIn])
				}
			})
			
		}else{
			STHelpers.showAlterView(title: "Oops", message: "Email and password cannot be empty", actionTitle: "I see", vc: self)
		}
	}
	
	func didTapGoogleSignInBtn(_ gesture: UITapGestureRecognizer) {
		print("didTapGoogleSignInBtn")
		GIDSignIn.sharedInstance().signIn()
		
	}
}

// MARK: - GIDSignInUIDelegate Google Auth
extension STSignInController: GIDSignInUIDelegate{
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		let spinner = MBProgressHUD.showAdded(to: self.view, animated: true)
		spinner.label.text = "Logging In..."
	}
}
