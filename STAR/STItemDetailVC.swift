//
//  ItemDetailViewController.swift
//  STAR
//
//  Created by chenglu li on 18/10/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import SnapKit
import WSTagsField
import JVFloatLabeledText

class SCItemDetailVC: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	
	let titleField = JVFloatLabeledTextField(frame: .zero)
	let titleFieldFontSize: CGFloat = 16
	let titleFieldFloatLabelFontSize: CGFloat = 14
	
	let tagsField = WSTagsField()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setUpUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setUpUI() {
		
		addDividerToBottom(superView: self.view, referredView: self.imageView, margin: 12)
		
		setUpTitleField()
		setUpTagView()
		
		self.view.addSubview(titleField)
		titleField.snp.makeConstraints { (make) in
			make.left.equalTo(self.imageView)
			make.right.equalTo(self.imageView)
			make.height.equalTo(40)
			make.top.equalTo(self.imageView.snp.bottom).offset(16)
		}

		addDividerToBottom(superView: self.view, referredView: titleField)
		
		let wrapperView = UIView()
		
		self.view.addSubview(wrapperView)
		wrapperView.snp.makeConstraints { (make) in
			make.left.equalTo(imageView)
			make.right.equalTo(imageView)
			make.height.equalTo(25)
			make.top.equalTo(titleField.snp.bottom).offset(12)
		}

		wrapperView.addSubview(tagsField)
		tagsField.snp.makeConstraints { (make) in
			make.edges.equalTo(wrapperView)
		}
		
		addDividerToBottom(superView: self.view, referredView: wrapperView)
	}
	
	func setUpTitleField() {

		titleField.font = UIFont.systemFont(ofSize: titleFieldFontSize)
		
		let placeHolderAttributes = [NSForegroundColorAttributeName: UIColor.lightGray]
		titleField.attributedPlaceholder = NSAttributedString(string: "Type The Title Here...", attributes: placeHolderAttributes)
		
		titleField.floatingLabelFont = UIFont.systemFont(ofSize: titleFieldFloatLabelFontSize)
		titleField.floatingLabelTextColor = STColors.themeBlue.toUIColor()
		
		titleField.placeholderYPadding = 6
		
		titleField.clearButtonMode = UITextFieldViewMode.whileEditing
		
		titleField.translatesAutoresizingMaskIntoConstraints = false;
		titleField.keepBaseline = true;

	}
	
	func setUpTagView() {
		tagsField.backgroundColor = .white
		tagsField.placeholder = "Tags"
		tagsField.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		tagsField.spaceBetweenTags = 8.0
		tagsField.font = .systemFont(ofSize: 14.0)
		tagsField.tintColor = STColors.themeBlue.toUIColor()
		tagsField.textColor = UIColor.white
		tagsField.fieldTextColor = .blue
		tagsField.selectedColor = UIColor.lightGray
		tagsField.selectedTextColor = .white
	}
	
	func addDividerToBottom(superView: UIView, referredView: UIView, margin: Int = 8) {
		
		let divider = UIView()
		divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
		
		superView.addSubview(divider)
		divider.snp.makeConstraints { (make) in
			make.left.equalTo(referredView)
			make.right.equalTo(referredView)
			make.height.equalTo(1)
			make.top.equalTo(referredView.snp.bottom).offset(margin)
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
