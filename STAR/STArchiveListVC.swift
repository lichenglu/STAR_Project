
//
//  STArchiveListViewController.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

private let reuseIdentifier = "archiveListCell"

class STArchiveListViewController: UICollectionViewController {
	
	let numberOfItemsPerRow: CGFloat = 1
	let archiveCellHeight: CGFloat = 200
	let minSpaceBetweenCells: CGFloat = 4
	let minLineSpaceBetweenCells: CGFloat = 8
	let sectionInsets = UIEdgeInsetsMake(0, 8, 8, 8)

	let realm = try! Realm()
	var dataSource: Results<STInstitution>? {
		didSet {
			self.collectionView?.reloadData()
		}
	}
	var notificationToken: NotificationToken?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
//		self.collectionView?.alwaysBounceVertical = true
		
		dataSource = STRealmDB.query(fromRealm: realm, ofType: STInstitution.self, query: "ownerId = '\(STUser.currentUserId)'")
		observeRealmChange(dataSource: dataSource)
		self.collectionView?.emptyDataSetSource = self;
		self.collectionView?.emptyDataSetDelegate = self;
		
		// Allow bouncing
		self.collectionView?.alwaysBounceVertical = true
		
//		print("results ", results.description)
//		try! FIRAuth.auth()?.signOut()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	deinit {
		notificationToken?.stop()
	}

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		guard let dataSource = dataSource else { return 0 }
        return dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! STArchiveCollectionViewCell
		
		guard let dataSource = dataSource,
			dataSource.count > indexPath.row else {
				return cell
		}
		
		let item = dataSource[indexPath.row]
		cell.configureUI(withHierarchy: item)
		
        return cell
    }
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
		print("Will display cell \(indexPath.row)")
	}
	
	// MARK: Helpers
	func pushToDetailView(owner: STContainer, titles: [String]) {
		guard let vc = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.archiveDetailVC.rawValue) as? STArchiveDetailVC
		else { return }
		vc.owner = owner
		vc.sectionTitles = titles
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func observeRealmChange(dataSource: Results<STInstitution>?) {
		// Set results notification block
		self.notificationToken = dataSource?.addNotificationBlock { (changes: RealmCollectionChange) in
			
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
					collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
					collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
					collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
					}, completion: { (finished) in
						if insertions.count > 0 {
							let indexPath = IndexPath(row: insertions.first!, section: 0)
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
	}
	
    // MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let dataSource = self.dataSource,
			dataSource.count > indexPath.row else {
				return
		}
		let item = dataSource[indexPath.row]
		self.pushToDetailView(owner: item, titles: item.hierarchyProperties)
	}

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension STArchiveListViewController: UICollectionViewDelegateFlowLayout{
	
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

 // MARK: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension STArchiveListViewController: DZNEmptyDataSetSource {
	
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

extension STArchiveListViewController: DZNEmptyDataSetDelegate {
	func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
		return true
	}
	
	func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
		return true
	}
}
