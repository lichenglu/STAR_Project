//
//  STSignInController.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Firebase

class STSignInController: UIViewController, GIDSignInUIDelegate {

	@IBOutlet weak var emailTextField: UITextField!
	
	@IBOutlet weak var pwTextField: UITextField!
	
	@IBOutlet weak var googleLoginView: UIView!
	
	@IBOutlet weak var signInBtn: UIButton!
	
	@IBOutlet weak var signInStackView: UIStackView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// UI Setting
		setUpUI()
		
		// HideKeyboardWhenTappedAround
		hideKeyboardWhenTappedAround()
		
		// Animation
		entryAnimation()
		
		GIDSignIn.sharedInstance().uiDelegate = self
		
	    // Uncomment to automatically sign in the user.
	    //GIDSignIn.sharedInstance().signInSilently()
			
	    // TODO(developer) Configure the sign-in button look/feel
	    // ...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setUpUI() {
		
		// Corner radius
		googleLoginView.layer.cornerRadius = 5
		googleLoginView.layer.masksToBounds = true
	}
	
	func entryAnimation(){
		let originalBounds = signInStackView.bounds
		signInStackView.bounds = CGRect(x: originalBounds.origin.x, y: self.view.frame.height, width: originalBounds.width, height: -originalBounds.height)
		UIView.animate(withDuration: 1) {
			self.signInStackView.bounds = originalBounds
		}
	}

	@IBAction func didTapLoginWithGoogle(_ sender: UIButton) {
		
	}
	
	@IBAction func didTapLoginWithEmail(_ sender: UIButton) {
		
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
