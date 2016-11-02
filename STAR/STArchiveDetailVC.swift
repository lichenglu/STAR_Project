//
//  STArchiveDetailVC.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import RealmSwift
import DZNEmptyDataSet
import MBProgressHUD

private let cellIdentifier = "archiveListCell"
private let headerIdentifier = "archiveHeader"

class STArchiveDetailVC: UICollectionViewController {
	
	let numberOfItemsPerRow: CGFloat = 2
	let archiveCellHeight: CGFloat = 200
	let minSpaceBetweenCells: CGFloat = 4
	let minLineSpaceBetweenCells: CGFloat = 8
	let sectionInsets = UIEdgeInsetsMake(8, 8, 8, 8)
	let headerViewHeight: CGFloat = 26
	
	let realm = try! Realm()
	var owner: STContainer?
	var dataSource:[AnyObject]? {
		didSet {
			print("dataSource", dataSource?.count)
		}
	}
	
	var notifTokens = [NotificationToken]()
	
	var sectionTitles: [String]?
	
	var saveBtn = UIBarButtonItem()
	
	var isSavingItem = false {
		didSet {
			if isSavingItem {

				saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(STArchiveDetailVC.didTapSaveBtn(_:)))
				
				let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(STArchiveDetailVC.didTapCancelSaveBtn(_:)))
				
				self.navigationItem.rightBarButtonItem = saveBtn
				self.navigationItem.leftBarButtonItem = cancel
				
			} else {
				let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(STArchiveDetailVC.didTapAddButton(sender:)))
				self.navigationItem.rightBarButtonItem = addBtn
				self.navigationItem.leftBarButtonItem = nil
			}
		}
	}
	
	var itemBeingSaved: STItemData?
	
	// MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
		setUpUI()
		
		// Notification
		STHelpers.addNotifObserver(to: self, selector: #selector(STArchiveDetailVC.savingItemStatusChanged(_:)), name: kSavingItemStatusDidChange, object: nil)
		
		guard let owner = self.owner else { return }
		dataSource = owner.children
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		mapRealmNotifToDataSource()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		notifTokens.forEach { (token) in
			token.stop()
		}
	}
	
	deinit {
		print("STArchiveDetailVC is gone")
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Helpers
	func setUpUI() {
		
		// Nav title
		if let owner = self.owner as? STHierarchy {
			self.title = owner.title
		}
		
		saveBtn.isEnabled = sectionTitles?.contains(STHierarchyType.item.plural()) ?? false
		
		// Allow bouncing
		self.collectionView?.alwaysBounceVertical = true
		
		// EmptyDataSet delegates
		self.collectionView?.emptyDataSetSource = self
		self.collectionView?.emptyDataSetDelegate = self
	}
	
	func open(container owner: STContainer, titles: [String]){
		guard let vc = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.archiveDetailVC.rawValue) as? STArchiveDetailVC
			else { return }
		vc.isSavingItem = self.isSavingItem
		vc.itemBeingSaved = self.itemBeingSaved
		vc.owner = owner
		vc.sectionTitles = titles
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func open(item: STItem) {
		guard let vc = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.itemDetailVC.rawValue) as? SCItemDetailVC
			else { return }
		vc.itemTitle = item.title
		vc.tags = item.tags
		vc.remoteImageURL = item.remoteImgURL
		let localImageURL = URL(fileURLWithPath: item.localImgURL)
		vc.localImageURL = localImageURL
		self.present(vc, animated: true, completion: nil)
	}
	
	func getItem(fromIndexPath indexPath: IndexPath) -> STHierarchy? {
		
		guard let dataSource = dataSource,
			dataSource.count > indexPath.section,
			dataSource[indexPath.section].count > indexPath.row
		else
		{
			return nil
		}
		
		var item: STHierarchy?
		
		if let items = dataSource[indexPath.section] as? Results<STBox>
		{
			item = items[indexPath.row]
		}
		else if let items = dataSource[indexPath.section] as? Results<STCollection>
		{
			item = items[indexPath.row]
		}
		else if let items = dataSource[indexPath.section] as? Results<STVolume>
		{
			item = items[indexPath.row]
		}
		else if let items = dataSource[indexPath.section] as? Results<STFolder>
		{
			item = items[indexPath.row]
		}
		else if let items = dataSource[indexPath.section] as? Results<STItem>
		{
			item = items[indexPath.row]
		}
		
		return item
	}
	
	// MARK: - Notification
	func savingItemStatusChanged(_ notification: Notification) {
		if let userInfo = notification.userInfo,
			let isSavingItem = userInfo["isSavingItem"] as? Bool{
			self.isSavingItem = isSavingItem
			
			if let itemBeingSaved = userInfo["item"] as? STItemData {
				print("itemBeingSaved exists")
				self.itemBeingSaved = itemBeingSaved
				mapRealmNotifToDataSource()
				saveBtn.isEnabled = sectionTitles?.contains(STHierarchyType.item.plural()) ?? false
			}
		}
	}
	
	// MARK: - Pragma
	func mapRealmNotifToDataSource() {
		guard let dataSource = dataSource, dataSource.count > 0
		else
		{
			return
		}
		
		if self.notifTokens.count > 0 {
			self.notifTokens.removeAll()
		}
		self.notifTokens.reserveCapacity(6)
		
		for (section, results) in dataSource.enumerated() {
			
			if let results = results as? Results<STBox>
			{
				addRealmNotif(results: results, section: section)
			}
			else if let results = results as? Results<STCollection>
			{
				addRealmNotif(results: results, section: section)
			}
			else if let results = results as? Results<STVolume>
			{
				addRealmNotif(results: results, section: section)
			}
			else if let results = results as? Results<STFolder>
			{
				addRealmNotif(results: results, section: section)
			}
			else if let results = results as? Results<STItem>
			{
				addRealmNotif(results: results, section: section)
			}
		}
	}
	
	func addRealmNotif<T: STHierarchy>(results: Results<T>, section: Int) {
		let token = results.addNotificationBlock { (changes: RealmCollectionChange) in
			guard let collectionView = self.collectionView else { return }
			switch changes {
			case .initial:
				// Results are now populated and can be accessed without blocking the UI
				collectionView.reloadData()
				break
			case .update(_, let deletions, let insertions, let modifications):
				// Query results have changed, so apply them to the collectionView
				collectionView.reloadEmptyDataSet()
				collectionView.performBatchUpdates({
					collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: section) })
					collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: section) })
					collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: section) })
					}, completion: { (finished) in
						if insertions.count > 0 {
							let indexPath = IndexPath(row: insertions.first!, section: section)
							collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
						}
				})
				
				break
			case .error(let err):
				// An error occurred while opening the Realm file on the background worker thread
				fatalError("\(err)")
				break
			}
		}
		self.notifTokens.append(token)
	}
	
	func showAddOptions() {
		let actionSheet = UIAlertController(title: "Add Something", message: "What hierarchy do you wanna add to?", preferredStyle: .actionSheet)
		self.sectionTitles?.forEach({ (title) in
			
			let action = UIAlertAction(title: title.capitalized, style: .default, handler: { [unowned self] (action) in
				
				guard let title = action.title?.lowercased(),
					 let owner = self.owner as? STHierarchy else { return }
				
				// If it users choose to create an item, then we open the
				// camera for them directly.
				if title == STHierarchyType.item.plural() {
					guard let rootVC = AppDelegate.stRootVC else { return }
					rootVC.showCamera()
					return
				}
				
				self.showTitleInputView(fileType: title, owner: owner)
			})
			
			actionSheet.addAction(action)
		})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		actionSheet.addAction(cancelAction)
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	func showTitleInputView(fileType: String, owner: STHierarchy) {
		
		let title = "File Name"
		let message = "Enter file name below"
		let textFieldPlaceholder = "What is the file name?"
		let confirmActionTitle = "Create"
		let cancelActionTitle = "Cancel"
		
		let submitAction = {
			[weak self] (title: String) in
			
			guard let this = self else { return }
			
			let realm = try! Realm()
			var newItem: STHierarchy!
			
			switch fileType.lowercased() {
			case STHierarchyType.box.plural():
				print("new box added")
				newItem = STBox()
				newItem.owner = owner
				newItem.title = title
			case STHierarchyType.collection.plural():
				print("new collection added")
				newItem = STCollection()
				newItem.owner = owner
				newItem.title = title
			case STHierarchyType.folder.plural():
				print("new folder added")
				newItem = STFolder()
				newItem.owner = owner
				newItem.title = title
			case STHierarchyType.volume.plural():
				print("new volume added")
				newItem = STVolume()
				newItem.owner = owner
				newItem.title = title
			default:
				print("About to create new item")
				return
			}
			
			STRealmDB.updateObject(inRealm: realm, object: newItem)
			this.dataSource = this.owner?.children
		}
		
		STHelpers.showAlertWithTextfield(title: title, message: message, textFieldPlaceholder: textFieldPlaceholder, confirmActionTitle: confirmActionTitle, confirmAction: submitAction, cancelActionTitle: cancelActionTitle, cancelAction: nil, vc: self)
	}
	
	func createItem() {
		guard let owner = self.owner as? STHierarchy else { return }
		guard let itemData = self.itemBeingSaved else { return }
		let realm = try! Realm()
		let newItem = itemData.toSTItem()
		newItem.owner = owner
		
		let spinner = MBProgressHUD.showAdded(to: self.view, animated: true)
		spinner.label.text = "Uploading Image"
		
		STRealmDB.updateObject(inRealm: realm, object: newItem)
		
		STFirebaseDB.db.uploadImageToFirebase(withUID: STUser.currentUserId, imageId: newItem.id, imagePath: newItem.localImgURL, metaData: newItem) { (metaData, error) in
			
			if error != nil {
				print(error)
			} else {
				guard let remoteURL = metaData?.downloadURL()
				else
				{
					print("Failed to get remoteURL")
					return
				}
				
				try! realm.write {
					newItem.remoteImgURL = remoteURL.absoluteString
				}
				
				print("The image's url is \(remoteURL.absoluteString)")
			}
			
			MBProgressHUD.hide(for: self.view, animated: true)
		}
		
		self.dataSource = self.owner?.children
	}
	
	// MARK: - User Actions
	func didTapAddButton(sender: UIBarButtonItem) {
		
		guard (self.collectionView?.numberOfSections) != nil
		else
		{
			return
		}
		
		showAddOptions()
	}
	
	func didTapCancelSaveBtn(_ sender: UIBarButtonItem) {
		self.isSavingItem = false
	}
	
	func didTapSaveBtn(_ sender: UIBarButtonItem) {
		createItem()
		isSavingItem = false
		STHelpers.postNotification(withName: kSavingItemStatusDidChange, userInfo: ["isSavingItem": self.isSavingItem])
		
		guard let rootVC = AppDelegate.stRootVC else { return }
		rootVC.isSavingItem = false
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
		guard let dataSource = dataSource else { return 0 }
        return dataSource.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		guard let dataSource = dataSource else { return 0 }
		return dataSource[section].count
    }

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! STArchiveCollectionViewCell
		
		cell.delegate = self
		
		guard let item = getItem(fromIndexPath: indexPath) else { return cell }
		
		cell.configureUI(withHierarchy: item)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: headerViewHeight)
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		switch kind {
		case UICollectionElementKindSectionHeader:
			let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! STArchiveHeaderView
			let title = sectionTitles?[indexPath.section] ?? "unknow"
			headerView.headerTitle.text = title.capitalized
			return headerView
		default:
			assert(false, "Unexpected element kind")
			return UICollectionReusableView()
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
	}

    // MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let item = getItem(fromIndexPath: indexPath) else { return }
		
		if let item = item as? STItem {
			self.open(item: item)
		}else if let itemData = item as? STContainer{
			self.open(container: itemData, titles: itemData.hierarchyProperties)
		}

	}
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */


    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//    
//    }


}

// MARK: UICollectionViewDelegateFlowLayout
extension STArchiveDetailVC: UICollectionViewDelegateFlowLayout{
	
	// Make each cell equal width, the amount of three equals window width
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: (collectionView.bounds.size.width - minSpaceBetweenCells * (2 * (numberOfItemsPerRow - 1)) - self.sectionInsets.left - self.sectionInsets.right)/numberOfItemsPerRow, height: self.archiveCellHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return self.minSpaceBetweenCells
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return self.minLineSpaceBetweenCells
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
		return self.sectionInsets
	}
	
}

// MARK: UICollectionViewDelegateFlowLayout
extension STArchiveDetailVC: STArchiveCellDelegate {
	
	func getIndexPathBy(cell: UICollectionViewCell) -> IndexPath? {
		guard let indexPath = self.collectionView?.indexPath(for: cell)
			else
		{
			return nil
		}
		
		return indexPath
	}
	
	func archiveCell(didTapRenameBtn cell: STArchiveCollectionViewCell) {
		
		let title = "Rename This Item?"
		let message =  "Rename it!"
		
		let confirmAction = {
			[weak self] (title: String) in
			guard let this = self else { return }
			guard let indexPath = this.getIndexPathBy(cell: cell)
			else
			{
				return
			}
			
			guard let target = this.getItem(fromIndexPath: indexPath)
			else
			{
				return
				
			}
			
			try! this.realm.write {
				target.title = title
			}
		}
		
		STHelpers.showAlertWithTextfield(title: title, message: message, confirmAction: confirmAction, cancelAction: nil, vc: self)

	}
	
	func archiveCell(didTapDeleteBtn cell: STArchiveCollectionViewCell) {
		
		let title = "Delete This Item?"
		let message =  "Do you really want to delete it? All related content will also be deleted and cannot be reversed"
		let confirmAction = {
			[weak self] (action: UIAlertAction) in
			guard let this = self else { return }
			guard let indexPath = this.getIndexPathBy(cell: cell)
			else
			{
				return
			}
			
			guard let target = this.getItem(fromIndexPath: indexPath)
			else
			{
				return
				
			}
			
			STRealmDB.deleteObject(in: this.realm, object: target)
		}
		
		STHelpers.showAlert(title: title, message: message, confirmAction: confirmAction, cancelAction: nil, vc: self)
	}
}

// MARK: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension STArchiveDetailVC: DZNEmptyDataSetSource {
	
	func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
		return STImageNames.emptyData.toUIImage()
	}
	
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let text = "Start Archiving Your Favorite Files Now"
		let font = UIFont.boldSystemFont(ofSize: 17)
		let textColor = UIColor.black
		let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor] as [String : Any]
		
		return NSAttributedString(string: text, attributes: attributes)
	}
	
	func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let text = "Favorites are saved for offline access."
		let font = UIFont.systemFont(ofSize: 14.5)
		let textColor = UIColor.darkGray
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineBreakMode = .byWordWrapping
		paragraph.alignment = .center
		
		let attributes = [NSFontAttributeName: font,
		                  NSForegroundColorAttributeName: textColor,
		                  NSParagraphStyleAttributeName: paragraph] as [String : Any]
		
		return NSAttributedString(string: text, attributes: attributes)
	}
	
	func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
		return UIColor(hexString: "f0f3f5")
	}
}

extension STArchiveDetailVC: DZNEmptyDataSetDelegate {
	func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
		return true
	}
	
	func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
		return true
	}
}
