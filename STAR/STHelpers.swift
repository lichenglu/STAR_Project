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
	
	class func postNotification(notificationName: String){
		let notification = Notification(name: Notification.Name(rawValue: notificationName))
		NotificationCenter.default.post(notification)
	}
}
