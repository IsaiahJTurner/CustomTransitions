//
//  SwipeablePresentationController.swift
//  CustomTransitions
//
//  Created by Isaiah Turner on 6/18/17.
//  Copyright © 2017 Isaiah Turner. All rights reserved.
//

import UIKit

class SwipeablePresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false // presentingViewController is SwipeableViewController
    }
    override var shouldPresentInFullscreen: Bool {
        return false
    }
}

