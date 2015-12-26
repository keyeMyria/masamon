//
//  CustomUICollectionViewCell.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/15.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import QuickLook

class CustomUICollectionViewCell: UICollectionViewCell{
    
    var textLabel:UILabel?
    var ql = QLPreviewController()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // UILabelを生成.
        textLabel = UILabel(frame: CGRectMake(0, 0, frame.width, 30))
        textLabel?.text = "nil"
        textLabel?.backgroundColor = UIColor.clearColor()
        textLabel?.textColor = UIColor.whiteColor()
        textLabel?.textAlignment = NSTextAlignment.Center
        
        //QLpreviewを表示させる
        ql.view.frame = CGRectMake(0,30,frame.width,frame.height-10)
        self.contentView.addSubview(ql.view)
        self.contentView.addSubview(textLabel!)
    }

}