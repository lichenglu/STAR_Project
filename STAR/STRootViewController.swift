//
//  STRootViewController.swift
//  STAR
//
//  Created by chenglu li on 26/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

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
		
		setUpUI()
		let currentUser = STUser.me()
		print("realm testing ", currentUser?.description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	
	// MARK: - Helpers
	
	private func setUpUI() {
		self.title = vcTitle
		setUpSegmentControl()
		setUpCameraBtn()
//		generateSeedData()
		
//		let realm = try! Realm()
//		guard let institution = realm.objects(STInstitution.self).first else { return }
//		print("institution")
//		print(institution.children)
//		print(institution.type)
//		print(institution.hierarchyProperties)
//		print(institution.boxes.description)
//		print(institution.id)
//		print(institution.ownerId)
	}
	
	private func setUpSegmentControl() {
		let titles = ["Archives", "To-dos", "Profile"]
		segmentedControl.setSegmentItems(titles)
		segmentedControl.delegate = self
		
		archiveListVC.view.isHidden = false
	}
	
	private func setUpCameraBtn() {
		
		let camera = STCameraButton()
		guard let currentWindow = UIApplication.shared.keyWindow else { return }
		currentWindow.addSubview(camera)
		currentWindow.bringSubview(toFront: camera)
		
		camera.snp.makeConstraints { (make) in
			make.centerX.equalTo(currentWindow)
			make.bottom.equalTo(currentWindow).offset(-20)
		}
		
		camera.addTarget(self, action: #selector(STRootViewController.didTapCameraButton(sender:)), for: .touchUpInside)
		
		// Camera tint color
		TGCameraColor.setTint(STColors.themeBlue.toUIColor())
		
		// Do not save photos to iPhone's photo app
		TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: false)
		
		// Hide filter button
		TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: true)
	}
	
	func generateSeedData(){
		let me = STUser.me()
		guard let ownerId = me?.uid else { assert(false, "No user logged in") }
		
		let realm = try! Realm()
		(0...15).forEach { (idx) in
			let institution = STInstitution()
			institution.ownerId = ownerId
			institution.title = "Test Institution\(idx)"
			STRealmDB.updateObject(inRealm: realm, object: institution)
		}
		
//		(0...4).forEach { (idx) in
//			let box = STBox()
//			box.ownerId = institution.id
//			box.title = "box\(idx)"
//			institution.boxes.append(box)
//		}
//		
//		(0...3).forEach { (idx) in
//			let collection = STCollection()
//			collection.ownerId = institution.id
//			collection.title = "collection\(idx)"
//			institution.collections.append(collection)
//		}
//		
//		(0...5).forEach { (idx) in
//			let volume = STVolume()
//			volume.ownerId = institution.id
//			volume.title = "volume\(idx)"
//			institution.volumes.append(volume)
//		}
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
	
	func didTapCameraButton(sender: STCameraButton){
		let navigationController = TGCameraNavigationController.new(with: self)
		present(navigationController!, animated: true, completion: nil)
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

// MARK: - Segmented Control delegate
extension STRootViewController: TwicketSegmentedControlDelegate {
	func didSelect(_ segmentIndex: Int) {
		print("didSelect \(segmentIndex)")
		archiveListVC.view.isHidden = !(segmentIndex == 0)
		toDoListVC.view.isHidden = !(segmentIndex == 1)
	}
}

// MARK: - TGCamera delegate
extension STRootViewController: TGCameraDelegate {
	
	// MARK: TGCameraDelegate - Required methods
	func cameraDidCancel() {
		dismiss(animated: true, completion: nil)
	}
	
	func cameraDidTakePhoto(_ image: UIImage!) {
		dismiss(animated: true, completion: nil)
	}
	
	func cameraDidSelectAlbumPhoto(_ image: UIImage!) {
		dismiss(animated: true, completion: nil)
	}
	
	
	// MARK: TGCameraDelegate - Optional methods
	func cameraWillTakePhoto() {
		print("cameraWillTakePhoto")
	}
	
	func cameraDidSavePhoto(atPath assetURL: URL!) {
		print("cameraDidSavePhotoAtPath: \(assetURL)")
	}
	
	func cameraDidSavePhotoWithError(_ error: Error!) {
		print("cameraDidSavePhotoWithError \(error)")
	}
}
