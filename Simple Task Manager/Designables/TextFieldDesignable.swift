//
//  TextFieldDesignable.swift
//  Simple Task Manager
//
//  Created by apple on 8/14/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

@IBDesignable
class TextFieldDesignable: UITextField {
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            
        }
    }
    
    
}
