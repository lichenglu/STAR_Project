//
//  STArchiveDetailVC.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import RealmSwift

private let cellIdentifier = "archiveListCell"
private let headerIdentifier = "archiveHeader"

class STArchiveDetailVC: UICollectionViewController {
	
	let numberOfItemsPerRow: CGFloat = 2
	let archiveCellHeight: CGFloat = 200
	let minSpaceBetweenCells: CGFloat = 4
	let minLineSpaceBetweenCells: CGFloat = 8
	let sectionInsets = UIEdgeInsetsMake(8, 8, 8, 8)
	let headerViewHeight: CGFloat = 26
	
	var owner: STContainer?
	var dataSource:[AnyObject]? {
		didSet {
			print("dataSource", dataSource?.count)
		}
	}
	var notifTokens = [NotificationToken]()
	
	var sectionTitles: [String]?
	
	// MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
		setUpUI()
		guard let owner = self.owner else { return }
		dataSource = owner.children
		mapRealmNotifToDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		notifTokens.forEach { (token) in
			token.stop()
		}
	}
	
	deinit {
		print("STArchiveDetailVC is gone")
	}
	
	// MARK: - Helpers
	func setUpUI() {
		
		// Nav title
		if let owner = self.owner as? STHierarchy {
			self.title = owner.title
		}
		
		// Add button
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(STArchiveDetailVC.didTapAddButton(sender:)))
		self.navigationItem.rightBarButtonItem = addButton
		
		// Allow bouncing
		self.collectionView?.alwaysBounceVertical = true
	}
	
	func openItem(owner: STContainer, titles: [String]){
		guard let vc = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.archiveDetailVC.rawValue) as? STArchiveDetailVC
			else { return }
		vc.owner = owner
		vc.sectionTitles = titles
		self.navigationController?.pushViewController(vc, animated: true)
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
	
	// MARK: - Pragma
	func mapRealmNotifToDataSource() {
		guard let dataSource = dataSource,
			  dataSource.count > 0
		else
		{
			return
		}
		
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
				
				collectionView.performBatchUpdates({
					collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: section) })
					collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: section) })
					collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: section) })
					}, completion: { (finished) in
						
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
				
				let realm = try! Realm()
				var newItem: STHierarchy!
				
				switch title.lowercased() {
				case "\(STHierarchyType.box)es":
					print("new box added")
					newItem = STBox()
					newItem.owner = owner
					newItem.title = "New Box"
					STRealmDB.addObject(toRealm: realm, object: newItem)
				case "\(STHierarchyType.collection)s":
					print("new collection added")
					newItem = STCollection()
					newItem.owner = owner
					newItem.title = "New Collection"
				case "\(STHierarchyType.folder)s":
					print("new folder added")
					newItem = STFolder()
					newItem.owner = owner
					newItem.title = "New Folder"
				case "\(STHierarchyType.volume)s":
					print("new volume added")
					newItem = STVolume()
					newItem.owner = owner
					newItem.title = "New Volume"
					
				default:
					print("unknown type")
				}
				
				STRealmDB.addObject(toRealm: realm, object: newItem)
				self.dataSource = self.owner?.children
			})
			
			actionSheet.addAction(action)
		})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		actionSheet.addAction(cancelAction)
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	// MARK: - User Actions
	func didTapAddButton(sender: UIBarButtonItem) {
		
		guard let numberOfSections = self.collectionView?.numberOfSections
		else
		{
			return
		}
		
		showAddOptions()
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
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
		print("Will display cell \(indexPath.row)")
		
		guard let cell = cell as? STArchiveCollectionViewCell else { return }
		
		guard let item = getItem(fromIndexPath: indexPath) else { return }
		
		DispatchQueue.main.async {
			cell.configureUI(withHierarchy: item)
		}
	}

    // MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let item = getItem(fromIndexPath: indexPath) else { return }
		
		if item is STItem {
			
		}else if let itemData = item as? STContainer{
			self.openItem(owner: itemData, titles: itemData.hierarchyProperties)
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

extension STArchiveDetailVC: UICollectionViewDelegateFlowLayout{
	
	// Make each cell equal width, the amount of three equals window width
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: (collectionView.bounds.size.width - minSpaceBetweenCells * 4 - self.sectionInsets.left - self.sectionInsets.right)/numberOfItemsPerRow, height: self.archiveCellHeight)
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
