//
//  UIColor+HexValue.swift
//  STAR
//
//  Created by chenglu li on 26/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation

extension UIColor {
	public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
		
		let start = hexString.hasPrefix("#") ? hexString.index(hexString.startIndex, offsetBy: 1) : hexString.index(hexString.startIndex, offsetBy: 0)
		let hexColor = hexString.substring(from: start)
		
		if hexColor.characters.count == 6 {
			let scanner = Scanner(string: hexColor)
			var hexNumber: UInt64 = 0
			
			if scanner.scanHexInt64(&hexNumber) {
				let red = CGFloat((hexNumber & 0xFF0000) >> 16)/256.0
				let green = CGFloat((hexNumber & 0xFF00) >> 8)/256.0
				let blue = CGFloat(hexNumber & 0xFF)/256.0
				
				self.init(red: red, green: green, blue: blue, alpha: alpha)
				return
			}
		}
		
		return nil
	}
}
