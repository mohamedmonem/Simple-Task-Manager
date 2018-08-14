//
//  Category.swift
//  Simple Task Manager
//
//  Created by apple on 8/14/18.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Category{
    var name : String?
    var color : String?
    
    init(name : String, color : String) {
        self.name = name
        self.color = color
    }
    
}
