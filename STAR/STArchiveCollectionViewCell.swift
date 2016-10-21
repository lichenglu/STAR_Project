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
	
	var cornerRadius: CGFloat = 5
	var shadowOpacity: Float = 0.8
	var shadowOffset: CGSize = CGSize.zero
	var shadowRadius: CGFloat = 1.5
	
	var isFirstTimeRendered = true
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		if isFirstTimeRendered {
			
			isFirstTimeRendered = false
			
			self.contentView.layer.cornerRadius = cornerRadius;
			self.contentView.layer.masksToBounds = true;
			
			layer.masksToBounds = false
			layer.cornerRadius = cornerRadius
			layer.shadowColor = STColors.shadowColor.toUIColor().cgColor
			layer.shadowOpacity = shadowOpacity
			layer.shadowOffset = shadowOffset
			layer.shadowRadius = shadowRadius
			layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
		}
	}
	
	func configureUI<T: STHierarchy>(withHierarchy data: T) {
	
		titleLabel.text = data.title
		self.backgroundColor = data.getBgColor()
		
		DispatchQueue.global().async {
			let image = data.getHierarchyImg()
			DispatchQueue.main.async {
				self.imageView.image = image
			}
		}
	}
}
