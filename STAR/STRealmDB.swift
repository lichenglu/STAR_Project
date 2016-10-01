//
//  STReamlDB.swift
//  STAR
//
//  Created by chenglu li on 27/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import RealmSwift

class STRealmDB {
	
	static func addObject(toRealm realmRef: Realm, object: Object) {
		try! realmRef.write {
			realmRef.add(object)
		}
	}
	
	static func updateObject(inRealm realmRef: Realm, object: Object) {
		try! realmRef.write {
			realmRef.add(object, update: true)
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
