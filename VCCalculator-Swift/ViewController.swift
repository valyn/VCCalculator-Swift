//
//  ViewController.swift
//  VCCalculator-Swift
//
//  Created by ValynCheng on 2017/6/13.
//  Copyright © 2017年 valyncheng. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let view : VCCalculatorView = VCCalculatorView.init(frame: self.view.frame)
        
        view.backgroundColor = UIColor.cyan
        self.view.addSubview(view)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

