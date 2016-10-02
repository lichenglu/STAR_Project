//
//  File.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class STInstitution: STHierarchy, STContainer {
	
	let boxes = List<STBox>()
	let collections = List<STCollection>()
	let volumes = List<STVolume>()
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.institution.rawValue])
	}
	
	var children: [AnyObject] {
		
		return [boxes, collections, volumes]
	}
	
	var hierarchyProperties: [String] {
		return ["boxes", "collections", "volumes"]
	}
	
	var firebaseRef: FIRDatabaseReference {
		return STFirebaseDB.db.refUser.child(ownerId).child("institutions").child(id)
	}
}
