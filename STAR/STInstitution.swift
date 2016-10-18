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
	
	var boxes: Results<STBox> {
		if let realm = self.realm {
			return realm.objects(STBox.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STBox>().filter("1 != 1")
		}
	}
	
	var collections: Results<STCollection> {
		if let realm = self.realm {
			return realm.objects(STCollection.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STCollection>().filter("1 != 1")
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
		return ReamlEnum(value: ["rawValue": STHierarchyType.institution.rawValue])
	}
	
	var children: [AnyObject] {
		
		return [boxes, collections, volumes]
	}
	
	var hierarchyProperties: [String] {
		return ["boxes", "collections", "volumes"]
	}
	
	override var firebaseRef: FIRDatabaseReference? {
		guard let ownerId = self.ownerId else { return nil }
		return STFirebaseDB.db.refUser.child(ownerId).child("institutions").child(id)
	}
}

extension STInstitution {
	
	override var properties: [String] {
		return ["id", "title", "ownerId"]
	}
	
	override func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		self.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		userData["boxes"] = Array(self.boxes.map({ (box) -> [String : Any] in
			return box.toDictionary()
		}))
		
		userData["collections"] = Array(self.collections.map({ (collection) -> [String : Any] in
			return collection.toDictionary()
		}))
		
		userData["volumes"] = Array(self.volumes.map({ (volume) -> [String : Any] in
			return volume.toDictionary()
		}))
		
		return userData
	}
}
