//
//  STCollection.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class STCollection: STHierarchy, STContainer {

	var items: Results<STItem> {
		if let realm = self.realm {
			return realm.objects(STItem.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STItem>().filter("1 != 1")
		}
	}
	
	var boxes: Results<STBox> {
		if let realm = self.realm {
			return realm.objects(STBox.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STBox>().filter("1 != 1")
		}
	}
	
	var volumes: Results<STVolume> {
		if let realm = self.realm {
			return realm.objects(STVolume.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STVolume>().filter("1 != 1")
		}
	}
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.collection.rawValue])
	}
	
	var children: [AnyObject]  {
		
		return [boxes, volumes, items]
	}
	
	var hierarchyProperties: [String] {
		return ["boxes", "volumes", "items"]
	}
	
	var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		let owner = STRealmDB.query(fromRealm: realm, ofType: STInstitution.self, query: "id = '\(ownerId!)'").first
		return owner?.firebaseRef?.child("collections").child(id)
	}
}
