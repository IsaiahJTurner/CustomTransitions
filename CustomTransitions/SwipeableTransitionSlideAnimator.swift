//
//  SwipeableTransitionSlideAnimator.swift
//  CustomTransitions
//
//  Created by Isaiah Turner on 6/18/17.
//  Copyright © 2017 Isaiah Turner. All rights reserved.
//

import UIKit

class SwipeableTransitionSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Delete this, not needed.
        self.transitionContext = transitionContext
        // Get all variables
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from) as! SwipeableViewController
        let toViewController = transitionContext.viewController(forKey: .to) as! SwipeableViewController
        let toView = transitionContext.view(forKey: .to) ?? toViewController.view!
        let fromView = transitionContext.view(forKey: .from) ?? fromViewController.view!
        
        let isPresenting = toViewController.presentingViewController == fromViewController
        let isFromMainViewController = fromViewController is MainViewController
        let isToMainViewController = toViewController is MainViewController
        
        if !isToMainViewController {
            toViewController.beginAppearanceTransition(true, animated: true)
        }
        if !isFromMainViewController {
            fromViewController.beginAppearanceTransition(false, animated: true)
        }
        // Set up the view heiarchy
        if isPresenting {
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
        } else {
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
        }
        var directionalViewOffset: CGFloat = 0
        
        if fromViewController.swipableViewControllerToPresentOnLeft == toViewController {
            directionalViewOffset = -containerView.frame.size.width
        } else if fromViewController.swipableViewControllerToPresentOnRight == toViewController {
            directionalViewOffset = containerView.frame.size.width
        } else if !isPresenting && toViewController.swipableViewControllerToPresentOnRight == fromViewController {
            directionalViewOffset = -containerView.frame.size.width
        } else if !isPresenting && toViewController.swipableViewControllerToPresentOnLeft == fromViewController {
            directionalViewOffset = containerView.frame.size.width
        } else {
            fatalError("Error: Unexpected view controller stack.")
        }
        
        if !isToMainViewController && isPresenting {
            toView.frame.origin.x = directionalViewOffset
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            if !isFromMainViewController {
                fromView.frame.origin.x = -directionalViewOffset
            }
            if !isToMainViewController {
                toView.frame.origin.x = 0
            }
            print("\(fromViewController) \(toViewController)")
            (fromViewController as? MainViewController)?.loadingView.layer.opacity = 0.0
            (toViewController as? MainViewController)?.loadingView.layer.opacity = 1.0
        }) { (completed) in
            transitionContext.completeTransition(!self.transitionContext!.transitionWasCancelled)
            if transitionContext.transitionWasCancelled {
                UIApplication.shared.keyWindow!.addSubview(fromView)
                if !isFromMainViewController {
                    fromViewController.beginAppearanceTransition(true, animated: true)
                }
                if !isToMainViewController {
                    toViewController.beginAppearanceTransition(false, animated: true)
                }
            } else {
                UIApplication.shared.keyWindow!.addSubview(toView)
            }
            if !isToMainViewController {
                toViewController.endAppearanceTransition()
            }
            if !isFromMainViewController {
                fromViewController.endAppearanceTransition()
            }
        }
    }
}
