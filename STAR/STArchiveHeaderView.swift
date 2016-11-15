//
//  STArchiveHeaderView.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

protocol STArchiveHeaderViewDelegate: class {
	func archiveHeaderView(didTapPlusBtn hierarchyText: String)
}

class STArchiveHeaderView: UICollectionReusableView {
        
	@IBOutlet weak var pluBtn: UIButton!
	@IBOutlet weak var headerTitle: UILabel!
	var isSavingItem = false {
		didSet {
			UIView.animate(withDuration: 0.5) {
				self.pluBtn.isHidden = !self.isSavingItem
			}
		}
	}
	
	weak var delegate: STArchiveHeaderViewDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		STHelpers.addNotifObserver(to: self, selector: #selector(STArchiveHeaderView.itemBeingSavedStatusDidChange(_:)), name: kSavingItemStatusDidChange, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func itemBeingSavedStatusDidChange(_ notification: Notification) {
		if let userInfo = notification.userInfo,
			let isSavingItem = userInfo["isSavingItem"] as? Bool{
			self.isSavingItem = isSavingItem
		}
	}
	
	@IBAction func didTapPlusBtn(_ sender: UIButton) {
		guard let hierarchyText = headerTitle.text else { return }
		delegate?.archiveHeaderView(didTapPlusBtn: hierarchyText)
	}
}
