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

protocol SCItemDetailVCDelegate {
	func itemDetailVC(didTapSaveToBtn vc: SCItemDetailVC, item: STItemData)
}

class SCItemDetailVC: ElasticModalViewController {

	@IBOutlet weak var imageView: UIImageView!
	
	var localImageURL: URL?
	var remoteImageURL: URL?
	var delegate: SCItemDetailVCDelegate?
	
	let titleField = JVFloatLabeledTextField(frame: .zero)
	let titleFieldFontSize: CGFloat = 16
	let titleFieldFloatLabelFontSize: CGFloat = 14
	
	let tagsField = WSTagsField()
	
	let confirmBtn = UIButton()
	
	// MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
		setUpUI()
		setUpImageView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Pragma
	fileprivate func  setUpImageView() {
		
		let fileManager = FileManager.default
		
		guard let localImageURL = localImageURL else { return }
		
		if fileManager.fileExists(atPath: localImageURL.path){
			
			DispatchQueue.global().async {
				
				guard let data = try? Data(contentsOf: localImageURL)
				else
				{
					return
				}
				
				guard let placeholder = STImageNames.emptyData.toUIImage()
				else
				{
					return
				}
				
				let image = UIImage(data: data) ?? placeholder
				DispatchQueue.main.async {
					self.imageView.image = image
				}
			}
		}
	}
	
	// MARK: - User Actions
	@IBAction func didClickSaveToBtn(_ sender: UIButton) {
		
		guard let titleText = titleField.text else { return }
		guard let localImgPath = localImageURL?.path else { return }
		
		let title = (titleText.replacingOccurrences(of: " ", with: "") == "") ? "New" : titleText
		
		let tags = tagsField.tags.map { (tag) -> String in
			return tag.text
		}
		
		let newItem = STItemData(title: title, tags: tags, localImgPath: localImgPath)
		
		self.delegate?.itemDetailVC(didTapSaveToBtn: self, item: newItem)
		self.dismiss(animated: true)
	}
	

	@IBAction func didClickCloseBtn(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: - UI Setups
	fileprivate func setUpUI() {
		
		addDividerToBottom(superView: self.view, referredView: self.imageView, margin: 12)
		
		setUpTitleField()
		setUpTagView()
		setUpBtn()
		
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
		
		self.view.addSubview(confirmBtn)
		confirmBtn.snp.makeConstraints { (make) in
			make.left.equalTo(imageView)
			make.right.equalTo(imageView)
			make.height.equalTo(35)
			make.top.equalTo(wrapperView.snp.bottom).offset(15)
		}
	}
	
	fileprivate func setUpTitleField() {

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
	
	fileprivate func setUpTagView() {
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
	
	fileprivate func setUpBtn() {
		confirmBtn.setTitle("Save", for: .normal)
		confirmBtn.backgroundColor = STColors.themeBlue.toUIColor()
	}
	
	fileprivate func addDividerToBottom(superView: UIView, referredView: UIView, margin: Int = 8) {
		
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

extension SCItemDetailVC {
	func elasticTransitionDidDismiss(_ transition: ElasticTransition) {
		print("I am dismissed")
	}
}
