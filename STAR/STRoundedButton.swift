//
//  STRoundedButton.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

@IBDesignable

class STRoundedButton: UIButton {
	
	@IBInspectable var cornerRadius: CGFloat = 5
	
	@IBInspectable var shadowRadius: CGFloat = 5.0
	@IBInspectable var shadowColor = UIColor(red: 120/255.0, green: 20/255.0, blue: 20/255.0, alpha: 0.8)
	@IBInspectable var shadowOpacity: Float = 0.8
	@IBInspectable var shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0)
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		// Add shadow to the button
		layer.shadowRadius = shadowRadius
		layer.shadowOpacity = shadowOpacity
		layer.shadowColor = shadowColor.cgColor
		layer.shadowOffset = shadowOffset
		layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
		
		// CornerRadius
		layer.cornerRadius = cornerRadius
	}
}
