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

	@IBOutlet weak var emailTextField: UITextField!
	
	@IBOutlet weak var pwTextField: UITextField!
	
	@IBOutlet weak var googleSignInBtn: GIDSignInButton!

	@IBOutlet weak var signInBtn: UIButton!
	
	@IBOutlet weak var signInStackView: UIStackView!
	
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
	    // Uncomment to automatically sign in the user.
		// GIDSignIn.sharedInstance().signInSilently()
		
		// Notification
		let notificationName = NSNotification.Name(kUserDidSuccessfullySignedIn)
		NotificationCenter.default.addObserver(self, selector:#selector(STSignInController.userDidLogin(notification:)), name: notificationName, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	private func entryAnimation(){
		let originalBounds = signInStackView.bounds
		signInStackView.bounds = CGRect(x: originalBounds.origin.x, y: self.view.frame.height, width: originalBounds.width, height: -originalBounds.height)
		UIView.animate(withDuration: 1) {
			self.signInStackView.bounds = originalBounds
		}
	}
	
	func userDidLogin(notification: Notification){
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func didTapLoginWithEmail(_ sender: UIButton) {
		
		let (email, pw, validated) = signInIsValidated()
		
		if(validated){
			
			FIRAuth.auth()?.signIn(withEmail: email!, password: pw!, completion: { (user, error) in
				
				if error != nil {
					
					FIRAuth.auth()?.createUser(withEmail: email!, password: pw!, completion: { (user, error) in
						
						if let error = error {
							STHelpers.showAlterView(title: "Oops", message: error.localizedDescription , actionTitle: "I see", vc: self)
						}else{
							STHelpers.postNotification(notificationName: kUserDidSuccessfullySignedIn)
						}
					})
					
				}else{
					STHelpers.postNotification(notificationName: kUserDidSuccessfullySignedIn)
				}
			})
			
		}else{
			STHelpers.showAlterView(title: "Oops", message: "Email and password cannot be empty", actionTitle: "I see", vc: self)
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
	
	func didTapGoogleSignInBtn(_ gesture: UITapGestureRecognizer) {
		print("didTapGoogleSignInBtn")
		GIDSignIn.sharedInstance().signIn()
	}
}

extension STSignInController: GIDSignInUIDelegate{

}
