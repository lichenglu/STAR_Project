//
//  STArchiveCollectionViewCell.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

class STArchiveCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.layer.cornerRadius = 5
		
		layer.shadowRadius = 2
		layer.shadowOpacity = 0.8
		layer.shadowColor = STColors.shadowColor.toUIColor().cgColor
		layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
	}
	
	func configureUI<T: STHierarchy>(withHierarchy data: T) {
		print("data", kHierarchyCoverImage + "\(data.type)")
		titleLabel.text = data.title
		let image = data.type.toUIImage()
		imageView.hnk_setImage(image, withKey: kHierarchyCoverImage + "\(data.type)")
	}
}
