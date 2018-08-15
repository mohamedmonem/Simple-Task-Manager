//
//  SettingsViewController.swift
//  Simple Task Manager
//
//  Created by apple on 8/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Action after clicking on add new category button (Open AddCategoryViewController)
    @IBAction func addNewCategoryBtnClicked(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddCategoryViewController")as! AddCategoryViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    

}
