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
	let camera = STCameraButton()
	var firstTimeRendered = true
	
	var isSavingItem = false {
		didSet {
			archiveListVC.isSavingItem = isSavingItem
			
			if isSavingItem {
				let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: nil)
				saveBtn.isEnabled = false
				
				let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(STRootViewController.didTapCancelSaveBtn(_:)))
				
				self.navigationItem.rightBarButtonItem = saveBtn
				self.navigationItem.leftBarButtonItem = cancel
				
			} else {
				let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(STRootViewController.didTapAddButton(_:)))
				self.navigationItem.rightBarButtonItem = addBtn
				self.navigationItem.leftBarButtonItem = nil
			}
		}
	}
	
	var itemBeingSaved: STItemData? {
		didSet {
			archiveListVC.itemBeingSaved = itemBeingSaved
		}
	}
	
	
	lazy var archiveListVC: STArchiveListViewController = {
		
		// Instantiate View Controller
		let viewController = self.storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.archiveListVC.rawValue) as! STArchiveListViewController
		
		// Add View Controller as Child View Controller
		self.addAsChildViewController(viewController: viewController)
		
		return viewController
	}()
	
	lazy var toDoListVC: STToDoListVC = {
		
		// Instantiate View Controller
		var viewController = self.storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.toDoListVC.rawValue) as! STToDoListVC
		
		// Add View Controller as Child View Controller
		self.addAsChildViewController(viewController: viewController)
		
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
	
	override func viewWillAppear(_ animated: Bool) {
		
		print("viewWillAppear")
		
		let hasLoggedIn = userHasLoggedin()
		
		if hasLoggedIn && firstTimeRendered {
			firstTimeRendered = false
			archiveListVC.view.isHidden = false
		}
	}
    
	
	// MARK: - Helpers
	private func userHasLoggedin() -> Bool {
		
		if STUser.me() == nil {
			guard let signInVC = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.signInVC.rawValue) as? STSignInController
			else
			{
				return false
			}
			
			self.present(signInVC, animated: false, completion: nil)
			
			return false
		}
		
		return true
	}
	
	private func setUpUI() {
		self.title = vcTitle
		setUpSegmentControl()
		setUpCameraBtn()
		
		let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(STRootViewController.didTapAddButton(_:)))
		self.navigationItem.rightBarButtonItem = addBtn
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
	}
	

	private func setUpCameraBtn() {
		
		guard let navView = self.navigationController?.view else { return }
		navView.addSubview(camera)
		navView.bringSubview(toFront: camera)
		
		camera.snp.makeConstraints { (make) in
			make.centerX.equalTo(navView)
			make.bottom.equalTo(navView).offset(-20)
		}
		
		camera.addTarget(self, action: #selector(STRootViewController.didTapCameraButton(sender:)), for: .touchUpInside)
		
		// Camera tint color
		TGCameraColor.setTint(STColors.themeBlue.toUIColor())
		
		// Do not save photos to iPhone's photo app
		TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: false)
		
		// Hide filter button
		TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: true)
	}
	
	private func generateSeedData(){

		guard let me = STUser.me() else { assert(false, "No user logged in");  return }
		
		let realm = try! Realm()
		(0...15).forEach { (idx) in
			let institution = STInstitution()
			institution.owner = me
			institution.ownerId = me.uid
			institution.title = "Test Institution\(idx)"
			STRealmDB.update(object: institution, inRealm: realm)
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
	
	private func addAsChildViewController(viewController: UIViewController) {
		
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
	
	private func addNewInstitutionWith(title: String) {
		guard let me = STUser.me()else { assert(false, "No user logged in"); return }
		let realm = try! Realm()
		let newInstitution = STInstitution()
		newInstitution.owner = me
		newInstitution.ownerId = me.uid
		newInstitution.title = title
		STRealmDB.update(object: newInstitution, inRealm: realm)
	}
	
	private func showTitleInputView() {
		
		let title = STTextPlaceholders.createHierarchyAlertTitle.rawValue
		let message = STTextPlaceholders.createHierarchyAlertMessage.rawValue
		let textFieldPlaceholder = "What is the file name?"
		let confirmActionTitle = "Create"
		let cancelActionTitle = "Cancel"
		
		let submitAction = {
			[weak self] (title: String) in
			
			guard let this = self else { return }
			
			this.addNewInstitutionWith(title: title)
		}
		
		STHelpers.showAlertWithTextfield(title: title, message: message, textFieldPlaceholder: textFieldPlaceholder, confirmActionTitle: confirmActionTitle, confirmAction: submitAction, cancelActionTitle: cancelActionTitle, cancelAction: nil, vc: self)
	}
	
	func showCamera() {
		guard let navigationController = TGCameraNavigationController.new(with: self)
			else
		{
			return
		}
		present(navigationController, animated: true, completion: nil)
	}
	
	// MARK: - Pragma
	private func saveImgToDisk(image: UIImage) {
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

	fileprivate func presentItemDetailView(withImageUrl url: URL) {
		guard let vc = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.itemDetailVC.rawValue) as? SCItemDetailVC
		else
		{
			return
		}
		vc.delegate = self
		vc.localImageURL = url
		vc.modalTransition.edge = .left
		vc.modalTransition.stiffness = 0.8
		vc.modalTransition.damping = 0.3
		self.present(vc, animated: true, completion: nil)
	}
	
	
	// MARK: - User actions
	
	func didTapCameraButton(sender: STCameraButton){
		showCamera()
	}
	
	func didTapCancelSaveBtn(_ sender: UIBarButtonItem) {
		self.isSavingItem = false
	}
	
	func didTapAddButton(_ sender: UIBarButtonItem) {
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

// MARK: - SCItemDetailVCDelegate
extension STRootViewController: SCItemDetailVCDelegate {
	func itemDetailVC(didTapSaveToBtn vc: SCItemDetailVC, item: STItemData)
	{
		self.isSavingItem = true
		self.itemBeingSaved = item
		STHelpers.postNotification(withName: kSavingItemStatusDidChange, userInfo: ["isSavingItem": self.isSavingItem, "item": item])
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
