//
//  SplashScreenVC.swift
//  Simple Task Manager
//
//  Created by apple on 8/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class SplashScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        perform(#selector(startHomePage), with: nil, afterDelay: 3)
        
        }
        
    @objc func startHomePage(){
        
        let mainStorybord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = mainStorybord.instantiateViewController(withIdentifier: "HomeNavigationController")
        
        UIApplication.shared.keyWindow?.rootViewController = VC
    
    
    }


}
