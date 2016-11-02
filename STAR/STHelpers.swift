//
//  STHelpers.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift

struct STHelpers {
	
	// MARK: - Alert View
	static func showAlterView(title: String, message: String, actionTitle: String?, vc: UIViewController){
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		let confirmAction = UIAlertAction(title: actionTitle ?? "OK", style: .default){ action in
			alert.dismiss(animated: true, completion: nil)
		}
		
		alert.addAction(confirmAction)
		vc.present(alert, animated: true, completion: nil)
	}
	
	static func showAlert(title: String, message: String, confirmActionTitle: String? = "Yes", confirmAction: ((UIAlertAction) -> Void)?, cancelActionTitle: String? = "Cancel", cancelAction: ((UIAlertAction) -> Void)?, vc: UIViewController) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default, handler: confirmAction)
		let cancelAction = UIAlertAction(title: cancelActionTitle, style: .destructive, handler: cancelAction)
		alert.addAction(confirmAction)
		alert.addAction(cancelAction)
		vc.present(alert, animated: true, completion: nil)
	}
	
	static func showAlertWithTextfield(title: String, message: String, textFieldPlaceholder: String? = "What is the file name?",confirmActionTitle: String? = "Yes", confirmAction: ((String) -> Void)?, cancelActionTitle: String? = "Cancel", cancelAction: ((UIAlertAction) -> Void)?, vc: UIViewController) {
		
		let alertController = UIAlertController(title: title,
		                                        message: message,
		                                        preferredStyle: .alert)
		
		alertController.addTextField { (textField) in
			textField.placeholder = textFieldPlaceholder
		}
		
		let submitAction = UIAlertAction(title: confirmActionTitle, style: .default) { (paramAction) in
			
			guard let textFields = alertController.textFields,
				let titleText = textFields.first?.text
				else
			{
				return
			}
			
			let title = (titleText.replacingOccurrences(of: " ", with: "") == "") ? "New" : titleText
			
			confirmAction?(title)
		}
		
		let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: cancelAction)
		
		alertController.addAction(submitAction)
		alertController.addAction(cancelAction)
		
		vc.present(alertController, animated: true, completion: nil)
	}
	
	
	// MARK: - Notifications
	static func postNotification(withName name: String, object: Any?, userInfo: [AnyHashable : Any]? ) {
		let notificationName = NSNotification.Name(name)
		NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
	}
	
	static func postNotification(withName name: String, userInfo: [AnyHashable : Any]? ){
		self.postNotification(withName: name, object: nil, userInfo: userInfo)
	}
	
	static func postNotification(withName name: String){
		self.postNotification(withName: name, object: nil, userInfo: nil)
	}
	
	static func addNotifObserver(to observer: Any, selector: Selector, name:  String, object: Any?){
		let notificationName = NSNotification.Name(name)
		NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: object)
	}
	
	// MARK: - Delay
	static func delay(withSeconds seconds: Double, completion: (() -> Void)?){
		let when = DispatchTime.now() + seconds
		DispatchQueue.main.asyncAfter(deadline: when){
			completion?()
		}
	}
	
}
