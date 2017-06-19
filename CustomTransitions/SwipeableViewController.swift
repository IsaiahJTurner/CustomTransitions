//
//  SwipeableViewController.swift
//  CustomTransitions
//
//  Created by Isaiah Turner on 6/18/17.
//  Copyright © 2017 Isaiah Turner. All rights reserved.
//

import UIKit

class SwipeableViewController: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    var swipableViewControllerToPresentOnLeft: UIViewController?
    var swipableViewControllerToPresentOnRight: UIViewController?
    var isSwipingEnabled = true {
        didSet {
            self.panGestureRecognizer.isEnabled = isSwipingEnabled
            if !isSwipingEnabled {
                self.interactor.cancel()
            }
        }
    }
    private(set) var isSwiping = false {
        didSet {
            if oldValue != self.isSwiping {
                self.isSwipingDidChange()
            }
        }
    }
    private var currentViewController: SwipeableViewController?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var interactor = SwipeableInteractiveTransition()
    private var panningTowardsSide: Side? {
        didSet {
            guard oldValue != panningTowardsSide else {
                return // Don't present when the value doesn't change.
            }
            guard let newValue = self.panningTowardsSide else {
                return // Do nothing if panning is dead center.
            }
            switch newValue {
            case .left:
                if let newVC = self.currentViewController!.swipableViewControllerToPresentOnRight {
                    self.present(newVC, animated: true, completion: nil)
                } else if (self.presentingViewController as? SwipeableViewController)?.swipableViewControllerToPresentOnLeft == self {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    return // Overscrolling
                }
            case .right:
                if let newVC = self.currentViewController!.swipableViewControllerToPresentOnLeft {
                    self.present(newVC, animated: true, completion: nil)
                } else if (self.presentingViewController as? SwipeableViewController)?.swipableViewControllerToPresentOnRight == self {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    return // Overscrolling
                }
            }
        }
    }
    /**
     Override to receive updates when the value of `isSwiping` changes.
     
     The default implementation does nothing.
     */
    func isSwipingDidChange() {}
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.currentViewController = self
        self.transitioningDelegate = self
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGestureRecognizer:)))
        self.panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = #colorLiteral(red: 1, green: 0.9490196078, blue: 0, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !(self is MainViewController) {
            self.view.backgroundColor = .clear
        }
    }
    
    internal func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let velocity = panGestureRecognizer.velocity(in: self.view)
        let translation = panGestureRecognizer.translation(in: self.view)
        let panningTowardsSide: Side? = {
            if (translation.x < 0) {
                return .left
            }
            if (translation.x > 0) {
                return .right
            }
            return nil
        }()
        
        if panningTowardsSide != self.panningTowardsSide && self.panningTowardsSide != nil {
            self.interactor.cancel()
        }
        
        switch panGestureRecognizer.state {
        case .began:
            self.interactor.hasStarted = true
            self.panningTowardsSide = panningTowardsSide
            self.isSwipingDidChange()
        case .changed:
            let progress = fabs(translation.x) / self.view.frame.width
            let isOverHalfwayThere = progress > 0.5
            let isSwipeableVelocity = fabs(velocity.x) > 1000
            let isVelocityInFinishingDirection = (panningTowardsSide == .left ? velocity.x <= 0 : velocity.x >= 0)
            self.isSwiping = progress > 0
            self.interactor.shouldFinish = (isOverHalfwayThere || isSwipeableVelocity) && isVelocityInFinishingDirection
            self.panningTowardsSide = panningTowardsSide
            self.interactor.update(progress)
        case .cancelled, .ended:
            self.isSwiping = false
            self.interactor.hasStarted = false
            self.panningTowardsSide = nil
            self.interactor.shouldFinish && panGestureRecognizer.state == .ended
                ? self.interactor.finish()
                : self.interactor.cancel()
            self.interactor.shouldFinish = false
        case .possible:
            print("Error: Swipeable panning gesture is possible.")
        case .failed:
            print("Error: Swipeable panning gesture failed.")
        }
    }
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let swipeableViewController = viewControllerToPresent as? SwipeableViewController {
            swipeableViewController.transitioningDelegate = self
            swipeableViewController.interactor = self.interactor
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        print("Dismissing \(self)")
        self.transitioningDelegate = self
        if let swipeableViewController = self.presentingViewController as? SwipeableViewController {
            swipeableViewController.transitioningDelegate = self
            swipeableViewController.interactor = self.interactor
        }
        super.dismiss(animated: flag, completion: completion)
    }
    // MARK: UIViewControllerTransitioningDelegate
    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is MainViewController {
            return SwipeableTransitionSlideAnimator() // Replace with slide down
        }
        return SwipeableTransitionSlideAnimator()
    }
    
    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwipeableTransitionSlideAnimator()
    }
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactor.hasStarted ? self.interactor : nil
    }
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactor.hasStarted ? self.interactor : nil
    }
    // MARK: UIGestureRecognizerDelegate
    final func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is SwipeableViewController {
            return SwipeablePresentationController(presentedViewController: presented, presenting: presenting)
        }
        return nil // Default
    }
}
