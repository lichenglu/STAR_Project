//
//  STRootViewController.swift
//  STAR
//
//  Created by chenglu li on 26/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

class STRootViewController: UIViewController {
	
	@IBOutlet weak var presentedView: UIView!
	@IBOutlet weak var segmentedControl: TwicketSegmentedControl!
	
	let vcTitle = "STAR"
	
	lazy var archiveListVC: STArchiveListViewController = {
		
		// Instantiate View Controller
		let viewController = self.storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.archiveListVC.rawValue) as! STArchiveListViewController
		
		// Add View Controller as Child View Controller
		self.addViewControllerAsChildViewController(viewController: viewController)
		
		return viewController
	}()
	
	lazy var toDoListVC: STToDoListVC = {
		
		// Instantiate View Controller
		var viewController = self.storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.toDoListVC.rawValue) as! STToDoListVC
		
		// Add View Controller as Child View Controller
		self.addViewControllerAsChildViewController(viewController: viewController)
		
		return viewController
	}()
	
	// MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
		
		checkIfUserHasLoggedin()
		
		setUpUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	
	// MARK: - Helpers
	
	func setUpUI() {
		self.title = vcTitle
		setUpSegmentControl()
	}
	
	func setUpSegmentControl() {
		let titles = ["Archives", "To-dos", "Profile"]
		segmentedControl.setSegmentItems(titles)
		segmentedControl.delegate = self
		
		archiveListVC.view.isHidden = false
	}
	
	private func addViewControllerAsChildViewController(viewController: UIViewController) {
		
		// Add Child View Controller
		addChildViewController(viewController)
		
		// Add Child View as Subview
		self.presentedView.addSubview(viewController.view)
		
		// Configure Child View
		viewController.view.frame = self.presentedView.bounds
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		// Notify Child View Controller
		viewController.didMove(toParentViewController: self)
	}
	
	private func checkIfUserHasLoggedin(){
		
		if !STUser.isLoggedIn() {
			
			if let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInVC"){
				self.present(signInVC, animated: false, completion: nil)
			}
		}
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

extension STRootViewController: TwicketSegmentedControlDelegate {
	func didSelect(_ segmentIndex: Int) {
		print("didSelect \(segmentIndex)")
		archiveListVC.view.isHidden = !(segmentIndex == 0)
		toDoListVC.view.isHidden = !(segmentIndex == 1)
	}
}
