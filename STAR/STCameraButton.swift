//
//  STCameraButton.swift
//  STAR
//
//  Created by chenglu li on 29/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import SnapKit

class STCameraButton: UIButton {
	
	var height = 60
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}


    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		self.snp.makeConstraints { (make) -> Void in
			make.width.height.equalTo(height)
		}
		
		let camera = UIImage(named: "camera")
		self.setImage(camera, for: .normal)
		self.imageView?.contentMode = .scaleAspectFit
    }


}
