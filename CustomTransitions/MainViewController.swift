//
//  ViewController.swift
//  CustomTransitions
//
//  Created by Isaiah Turner on 6/18/17.
//  Copyright © 2017 Isaiah Turner. All rights reserved.
//

import UIKit

class MainViewController: SwipeableViewController {

    @IBOutlet var loadingView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipableViewControllerToPresentOnRight = self.storyboard?.instantiateViewController(withIdentifier: "rightVC")
        self.swipableViewControllerToPresentOnLeft = self.storyboard?.instantiateViewController(withIdentifier: "leftVC")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func next(_ sender: UIButton) {
        self.present(self.swipableViewControllerToPresentOnRight!, animated: true)
    }
}

