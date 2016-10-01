//
//  STFolder.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift


class STFolder: STHierarchy, STContainer {
	let items = List<STItem>()
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.folder.rawValue])
	}
	
	var children: [[AnyObject]] {
		
		var result = [[AnyObject]]()
		var tempArr = [AnyObject]()
		
		items.forEach{ tempArr.append($0) }
		result.append(tempArr)
		
		return result
	}
	
	var hierarchyProperties: [String] {
		return ["items"]
	}
}
