//
//  Task.swift
//  Simple Task Manager
//
//  Created by apple on 8/14/18.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Task{
    var categoryName : String?
    var categoryColor : String?
    var date : String?
    var title : String?
    
    init(categoryName : String, categoryColor : String,date: String, title: String) {
        self.categoryName = categoryName
        self.categoryColor = categoryColor
        self.date = date
        self.title = title
    }
    
}
