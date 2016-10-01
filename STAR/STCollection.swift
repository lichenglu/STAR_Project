//
//  STCollection.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift

class STCollection: STHierarchy, STContainer {
	
	let boxes = List<STBox>()
	let volumes = List<STVolume>()
	let items = List<STItem>()
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.collection.rawValue])
	}
	
	var children: [[AnyObject]] {
		
		var result = [[AnyObject]]()
		var tempArr = [AnyObject]()
		
		boxes.forEach{ tempArr.append($0) }
		result.append(tempArr)
		tempArr.removeAll()
		
		volumes.forEach{ tempArr.append($0) }
		result.append(tempArr)
		tempArr.removeAll()
		
		items.forEach{ tempArr.append($0) }
		result.append(tempArr)
		
		return result
	}
	
	var hierarchyProperties: [String] {
		return ["boxes", "volumes", "items"]
	}
}
