//
//  STItem.swift
//  STAR
//
//  Created by chenglu li on 29/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class STItem: STHierarchy {
	
	dynamic var localImgURL: String!
	dynamic var remoteImgURL: String? = nil
	
	var tags: [String] {
		get {
			return _backingTags.map { $0.stringValue }
		}
		set {
			_backingTags.removeAll()
			_backingTags.append(objectsIn: newValue.map({ RealmString(value: [$0]) }))
		}
	}
	
	private let _backingTags = List<RealmString>()
	
	override static func ignoredProperties() -> [String] {
		return ["tags"]
	}
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.item.rawValue])
	}
	
	override var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		if let owner = STRealmDB.query(fromRealm: realm, ofType: STFolder.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("items").child(id)
		}else if let owner = STRealmDB.query(fromRealm: realm, ofType: STCollection.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("items").child(id)
		}else if let owner = STRealmDB.query(fromRealm: realm, ofType: STVolume.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("items").child(id)
		}
		return nil
	}
}

extension STItem {
	
	override var properties: [String] {
		return ["ownerId", "id",
		        "title", "tags"]
	}
	
	override func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		self.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		
		return userData
	}
}
