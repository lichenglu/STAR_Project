//
//  STItem.swift
//  STAR
//
//  Created by chenglu li on 29/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift

class STItem: STHierarchy {
	
	dynamic var imageURL: String!
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
}

extension STItem: STRealmModel {
	
	static var properties: [String] {
		return ["ownerId", "id",
		        "title", "tags"]
	}
	
	func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		STItem.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		
		return userData
	}
}
