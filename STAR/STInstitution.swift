//
//  File.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift

class STInstitution: STHierarchy, STContainer {
	
	let boxes = List<STBox>()
	let collections = List<STCollection>()
	let volumes = List<STVolume>()
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.institution.rawValue])
	}
	
	var children: [[AnyObject]] {
		
		var result = [[AnyObject]]()
		var tempArr = [AnyObject]()
		
		boxes.forEach{ tempArr.append($0) }
		result.append(tempArr)
		tempArr.removeAll()
		
		collections.forEach{ tempArr.append($0) }
		result.append(tempArr)
		tempArr.removeAll()
		
		volumes.forEach{ tempArr.append($0) }
		result.append(tempArr)
		
		return result
	}
	
	var hierarchyProperties: [String] {
		return ["boxes", "collections", "volumes"]
	}
}
