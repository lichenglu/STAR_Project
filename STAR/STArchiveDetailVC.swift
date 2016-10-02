//
//  STArchiveDetailVC.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

private let cellIdentifier = "archiveListCell"
private let headerIdentifier = "archiveHeader"

class STArchiveDetailVC: UICollectionViewController {
	
	let numberOfItemsPerRow: CGFloat = 2
	let archiveCellHeight: CGFloat = 200
	let minSpaceBetweenCells: CGFloat = 4
	let minLineSpaceBetweenCells: CGFloat = 8
	let sectionInsets = UIEdgeInsetsMake(8, 8, 8, 8)
	let headerViewHeight: CGFloat = 26
	
	var dataSource:[[AnyObject]]? {
		didSet {
			self.collectionView?.reloadData()
			print("dataSource", dataSource?.count)
		}
	}
	
	var sectionTitles: [String]?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		self.collectionView?.alwaysBounceVertical = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Helpers
	func openItem(dataSource: [[AnyObject]], titles: [String]){
		guard let vc = storyboard?.instantiateViewController(withIdentifier: STStoryboardIds.archiveDetailVC.rawValue) as? STArchiveDetailVC
			else { return }
		vc.dataSource = dataSource
		vc.sectionTitles = titles
		self.navigationController?.pushViewController(vc, animated: true)
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
		
		guard let dataSource = dataSource,
			dataSource.count > indexPath.section,
			dataSource[indexPath.section].count > indexPath.row else {
				return cell
		}
		
//		if let item = dataSource[indexPath.section][indexPath.row] as? STBox
//		{
//			cell.configureUI(withHierarchy: item)
//		}
//		else if let item = dataSource[indexPath.section][indexPath.row] as? STCollection
//		{
//			cell.configureUI(withHierarchy: item)
//		}
//		else if let item = dataSource[indexPath.section][indexPath.row] as? STVolume
//		{
//			cell.configureUI(withHierarchy: item)
//		}
		
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
		
		guard let dataSource = dataSource,
			  dataSource.count > indexPath.section,
			  dataSource[indexPath.section].count > indexPath.row,
		      let cell = cell as? STArchiveCollectionViewCell
		
		else
		{
			return
		}
		
		let item = dataSource[indexPath.section][indexPath.row]
		
		DispatchQueue.main.async {
			cell.configureUI(withHierarchy: item as! STHierarchy)
		}
	}

    // MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let dataSource = dataSource,
				  dataSource.count > indexPath.section,
				  dataSource[indexPath.section].count > indexPath.row else {
			return
		}
		
		let item = dataSource[indexPath.section][indexPath.row]
		
		if let item = item as? STItem {
			
		}else if let item = item as? STContainer{
			self.openItem(dataSource: item.children, titles: item.hierarchyProperties)
		}

	}
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

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
