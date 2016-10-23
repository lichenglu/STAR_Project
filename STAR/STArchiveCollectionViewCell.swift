//
//  STArchiveCollectionViewCell.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import SnapKit

class STArchiveCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var iconImg: UIImageView!
	@IBOutlet weak var itemImg: UIImageView?
	
	var cornerRadius: CGFloat = 5
	var shadowOpacity: Float = 0.8
	var shadowOffset: CGSize = CGSize.zero
	var shadowRadius: CGFloat = 1.5
	
	var isFirstTimeRendered = true
	
	override func awakeFromNib() {
		super.awakeFromNib()
		itemImg?.isHidden = true
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

		itemImg?.isHidden = !(data.type == .item)
		iconImg.isHidden = (data.type == .item)
		
		if  let itemImg = itemImg,
			let data = data as? STItem,
			!(itemImg.isHidden) {
			setUpImageView(with: data)
			
		} else {
			DispatchQueue.global().async {
				let image = data.getHierarchyImg()
				DispatchQueue.main.async {
					self.iconImg.image = image
				}
			}
		}
	}
	
	fileprivate func setUpImageView(with item: STItem) {
		
		let fileManager = FileManager.default
		
		guard let localImagePath = item.localImgURL else { return }
		
		guard let placeholder = STImageNames.emptyData.toUIImage()
		else
		{
			return
		}
		
		let url = URL(fileURLWithPath: localImagePath)
		
		if fileManager.fileExists(atPath: url.path) {
			
			DispatchQueue.global().async {
				
				guard let data = try? Data(contentsOf: url)
				else
				{
					return
				}
				
				let image = UIImage(data: data) ?? placeholder
				DispatchQueue.main.async {
					self.itemImg?.image = image
				}
			}
			
		} else {
			
			guard let remoteURL = item.remoteImgURL,
				let url = URL(string: remoteURL)
			else
			{
				return
			}
			
			self.itemImg?.hnk_setImage(from: url, placeholder: placeholder)
		}
	}
}
