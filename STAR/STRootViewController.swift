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
//		guard let institution = realm.objects(STInstitution.self).first
//		else
//		{
//			return
//		}
//		
//		print("institution")
//		print(institution.firebaseRef)
//		print(institution.boxes.first?.firebaseRef)
//		print(institution.collections.first?.firebaseRef)
//		print(institution.volumes.first?.firebaseRef)
	}
	
	private func setUpSegmentControl() {
		let titles = ["Archives", "To-dos", "Profile"]
		segmentedControl.setSegmentItems(titles)
		segmentedControl.sliderBackgroundColor = STColors.themeBlue.toUIColor()
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

		guard let me = STUser.me() else { assert(false, "No user logged in");  return }
		
		let realm = try! Realm()
		(0...15).forEach { (idx) in
			let institution = STInstitution()
			institution.owner = me
			institution.ownerId = me.uid
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
	
	func addANewInstitution(title: String) {
		guard let me = STUser.me()else { assert(false, "No user logged in"); return }
		let realm = try! Realm()
		let newInstitution = STInstitution()
		newInstitution.owner = me
		newInstitution.ownerId = me.uid
		newInstitution.title = title
		STRealmDB.updateObject(inRealm: realm, object: newInstitution)
	}
	
	func showTitleInputView() {
		
		let alertController = UIAlertController(title: "File Name",
		                                        message: "Enter file name below",
		                                        preferredStyle: .alert)
		
		alertController.addTextField { (textField) in
			textField.placeholder = "What is the file name?"
		}
		
		let submitAction = UIAlertAction(title: "Create", style: .default) { [weak self](paramAction) in
			
			guard let textFields = alertController.textFields,
				let titleText = textFields.first?.text
			else
			{
				return
			}
			
			let title = (titleText.replacingOccurrences(of: " ", with: "") == "") ? "New" : titleText
			
			self?.addANewInstitution(title: title)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alertController.addAction(submitAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	// MARK: - Pragma
	func saveImgToDisk(image: UIImage) {
		let fileManager = FileManager.default
		guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
		let imageDir = documentURL.appendingPathComponent("Images")
		let imgName = NSUUID().uuidString.appending(".jpg")
		
		let imageURL = imageDir.appendingPathComponent(imgName)
		
		print("imageURL \(imageURL)")
		let imageData = UIImageJPEGRepresentation(image, 1)
		
		if fileManager.fileExists(atPath: imageDir.path) {
			let succeeded = fileManager.createFile(atPath: imageURL.path as String, contents: imageData, attributes: nil)
			print(succeeded)
		}else {
			do {
				try fileManager.createDirectory(at: imageDir, withIntermediateDirectories: true, attributes: nil)
				let succeeded = fileManager.createFile(atPath: imageURL.path as String, contents: imageData, attributes: nil)
				print(succeeded)
			}catch {
				print(error)
			}
		}
	}

	func presentItemDetailView(withImageUrl url: URL) {
		guard let vc = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.itemDetailVC.rawValue) as? SCItemDetailVC
		else
		{
			return
		}
		
		vc.localImageURL = url
		
		self.present(vc, animated: true, completion: nil)
	}
	
	
	// MARK: - User actions
	
	func didTapCameraButton(sender: STCameraButton){
		guard let navigationController = TGCameraNavigationController.new(with: self)
		else
		{
			return
		}
		present(navigationController, animated: true, completion: nil)
	}
	
	@IBAction func didTapAddButton(_ sender: UIBarButtonItem) {
		if segmentedControl.selectedSegmentIndex == 0 {
			showTitleInputView()
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

		guard let assetURL = assetURL else { return }
		presentItemDetailView(withImageUrl: assetURL)
	}
	
	func cameraDidSavePhotoWithError(_ error: Error!) {
		print("cameraDidSavePhotoWithError \(error)")
	}
}
