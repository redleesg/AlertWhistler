//
//  ViewController.swift
//  AlertWhistler
//
//  Created by redleesg on 09/17/2018.
//  Copyright (c) 2018 redleesg. All rights reserved.
//

import UIKit
import AlertWhistler

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {
    
    @IBAction func showOnStatusBar() {
        AlertWhistler.whisper(text: "show text on status bar").show()
    }
    
    @IBAction func showOnStatusAndNavigationBar() {
        AlertWhistler.notice(text: "show text on status and navigation bar").show()
    }
    
}
