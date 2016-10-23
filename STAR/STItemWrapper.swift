//
//  STItemWrapper.swift
//  STAR
//
//  Created by chenglu li on 23/10/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation

struct STItemData {
	let title: String
	let tags: [String]
	let localImgPath: String
	
	func toSTItem() -> STItem {
		let item = STItem()
		item.tags = self.tags
		item.title = self.title
		item.localImgURL = self.localImgPath
		
		return item
	}
}
