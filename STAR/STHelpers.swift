//
//  STHelpers.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation

class STHelpers {
	
	class func showAlterView(title: String, message: String, actionTitle: String?, vc: UIViewController){
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		let confirmAction = UIAlertAction(title: actionTitle ?? "OK", style: .default){ action in
			alert.dismiss(animated: true, completion: nil)
		}
		
		alert.addAction(confirmAction)
		vc.present(alert, animated: true, completion: nil)
	}
	
	
	// MARK: - Notifications
	class func postNotification(withName name: String, object: Any?, userInfo: [AnyHashable : Any]? ) {
		let notificationName = NSNotification.Name(name)
		NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
	}
	
	class func postNotification(withName name: String, userInfo: [AnyHashable : Any]? ){
		self.postNotification(withName: name, object: nil, userInfo: userInfo)
	}
	
	class func postNotification(withName name: String){
		self.postNotification(withName: name, object: nil, userInfo: nil)
	}
	
	class func addNotifObserver(to observer: Any, selector: Selector, name:  String, object: Any?){
		let notificationName = NSNotification.Name(name)
		NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: object)
	}
}
