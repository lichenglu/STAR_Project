//
//  STReamlDB.swift
//  STAR
//
//  Created by chenglu li on 27/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import RealmSwift
import Firebase

class STRealmDB {
	
	static func add(object: Object, toRealm realmRef: Realm) {
		try! realmRef.write {
			realmRef.add(object)
			if let object = object as? STHierarchy,
				let ref = object.firebaseRef{
				STFirebaseDB.db.updateHierarchyOnFirebase(withRef: ref, data: object.toDictionary())
			}
		}
	}
	
	static func update(object: Object, inRealm realmRef: Realm) {
		try! realmRef.write {
			realmRef.add(object, update: true)
			if let object = object as? STHierarchy,
			   let ref = object.firebaseRef{
				STFirebaseDB.db.updateHierarchyOnFirebase(withRef: ref, data: object.toDictionary())
			}
		}
	}
	
	static func delete(object: Object, inRealm realmRef: Realm) {
		
		try! realmRef.write {
			if let object = object as? STHierarchy,
				let reference = object.firebaseRef {
				STFirebaseDB.db.deleteHierarchy(on: reference)
			}
			realmRef.delete(object)
		}
	}
	
	static func query<T: Object>(fromRealm realmRef: Realm, ofType type: T.Type, query: String) -> Results<T> {
		return realmRef.objects(T.self).filter(query)
	}
	
	static func deleteRealm() {
		let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
		let realmURLs = [
			realmURL,
			realmURL.appendingPathExtension("lock"),
			realmURL.appendingPathExtension("log_a"),
			realmURL.appendingPathExtension("log_b"),
			realmURL.appendingPathExtension("note")
		]
		for URL in realmURLs {
			do {
				try FileManager.default.removeItem(at: URL)
			} catch {
			}
		}
	}
	
	static func migrateRealmModelV1() {
		
		let config = Realm.Configuration(
			// Set the new schema version. This must be greater than the previously used
			// version (if you've never set a schema version before, the version is 0).
			schemaVersion: 2,
			
			// Set the block which will be called automatically when opening a Realm with
			// a schema version lower than the one set above
			migrationBlock: { migration, oldSchemaVersion in
				// We haven’t migrated anything yet, so oldSchemaVersion == 0
				if (oldSchemaVersion < 2) {
					// Nothing to do!
					// Realm will automatically detect new properties and removed properties
					// And will update the schema on disk automatically
				}
		})
		
		// Tell Realm to use this new configuration object for the default Realm
		Realm.Configuration.defaultConfiguration = config
		
		// Now that we've told Realm how to handle the schema change, opening the file
		// will automatically perform the migration
		_ = try! Realm()
	}
}
