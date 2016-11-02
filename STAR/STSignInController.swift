//
//  STSignInController.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import MBProgressHUD

class STSignInController: UIViewController {
	
	// MARK: - IBOulets
	@IBOutlet weak var emailTextField: UITextField!
	
	@IBOutlet weak var pwTextField: UITextField!
	
	@IBOutlet weak var googleSignInBtn: GIDSignInButton!

	@IBOutlet weak var signInBtn: UIButton!
	
	@IBOutlet weak var signInStackView: UIStackView!
	
	var hasSeenAnimation = false
	
	var realmRef: Realm!
	
	// MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Init realm
		realmRef = try! Realm()
		
		// HideKeyboardWhenTappedAround
		hideKeyboardWhenTappedAround()
		
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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Animation
		if !hasSeenAnimation{
			self.animateWhenEntering()
			hasSeenAnimation = true
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - helpers
	private func animateWhenEntering(){
		let originalFrame = self.signInStackView.frame
		self.signInStackView.frame = CGRect(x: originalFrame.origin.x, y: self.view.frame.height, width: originalFrame.width, height: originalFrame.height)
		UIView.animate(withDuration: 1) {
			self.signInStackView.frame = originalFrame
		}
	}
	
	fileprivate func showSpinner() {
		let spinner = MBProgressHUD.showAdded(to: self.view, animated: true)
		spinner.label.text = "Logging In..."
	}
	
	private func signInIsValidated() -> (email: String?, pw: String?, success: Bool){
		
		if let email = emailTextField.text,
			let pw = pwTextField.text,
			email.trimmingCharacters(in: .whitespaces) != "",
			pw.trimmingCharacters(in: .whitespaces) != ""{
			
			return (email, pw, true)
		}
		
		return (nil, nil, false)
	}
	
	// MARK: - Notification
	@objc private func userLoginStatusDidChange(notification: Notification){
		
		guard let userInfo = notification.userInfo,
			let loginStatus = userInfo["loginStatus"] as? STUserLoginStatus else {
				return
		}
		
		switch loginStatus {
			
		case .loggedIn(let user):
			
			if let user = user {
				UserDefaults.standard.setValue(user.uid, forKey: kCurrentUserUID)
				let currentUser = STUser(withFIRUser: user)
				STRealmDB.update(object: currentUser, inRealm: realmRef)
				STFirebaseDB.db.createUserOnFirebase(withSTUser: currentUser)
			}
			
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
		
		self.showSpinner()
		
		let (email, pw, validated) = signInIsValidated()
		
		if(validated){
			
			FIRAuth.auth()?.signIn(withEmail: email!, password: pw!, completion: { (user, error) in
				
				if error != nil {
					
					FIRAuth.auth()?.createUser(withEmail: email!, password: pw!, completion: { (user, error) in
						
						if let error = error {
							STHelpers.showAlterView(title: "Oops", message: error.localizedDescription , actionTitle: "I see", vc: self)
							STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.failed(error: error)])
						}else{
							STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.loggedIn(user: user)])
						}
					})
					
				}else{
					STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.loggedIn(user: user)])
				}
			})
			
		}else{
			STHelpers.showAlterView(title: "Oops", message: "Email and password cannot be empty", actionTitle: "I see", vc: self)
		}
	}
	
	@objc private func didTapGoogleSignInBtn(_ gesture: UITapGestureRecognizer) {
		print("didTapGoogleSignInBtn")
		GIDSignIn.sharedInstance().signIn()
		self.showSpinner()
	}
}

// MARK: - GIDSignInUIDelegate Google Auth
extension STSignInController: GIDSignInUIDelegate{

}
