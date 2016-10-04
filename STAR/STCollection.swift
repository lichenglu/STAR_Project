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
	
	override var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		let owner = STRealmDB.query(fromRealm: realm, ofType: STInstitution.self, query: "id = '\(ownerId!)'").first
		return owner?.firebaseRef?.child("collections").child(id)
	}
}

extension STCollection {
	
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
		
		userData["items"] = Array(self.items.map({ (item) -> [String : Any] in
			return item.toDictionary()
		}))
		
		userData["volumes"] = Array(self.volumes.map({ (volume) -> [String : Any] in
			return volume.toDictionary()
		}))
		
		return userData
	}
}
