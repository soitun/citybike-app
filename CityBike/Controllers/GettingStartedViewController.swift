//
//  GettingStartedViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class GettingStartedViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var finalBackgroundImageView: UIImageView!
    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var finalLogoImageView: UIImageView!
    @IBOutlet weak var startLogoImageView: UIImageView!
    @IBOutlet weak var logoContainerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var thanksButton: CustomButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        finalBackgroundImageView.alpha = 0
        finalLogoImageView.alpha = 0
        
        pageControl.alpha = 0
        pageControl.numberOfPages = self.tutorialPages().count
        scrollView.alpha = 0
       
        thanksButton.alpha = 0
        thanksButton.enabled = false
        thanksButton.makeStyleEndGettingStarted()
        thanksButton.setTitle(NSLocalizedString("that-is-easy-thanks", comment: ""), forState: .Normal)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        logoContainerBottomConstraint.constant = CGRectGetHeight(self.view.frame) - 40.0
        UIView.animateWithDuration(0.7, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.finalBackgroundImageView.alpha = 1
            self.startLogoImageView.alpha = 0
            self.finalLogoImageView.alpha = 1
            self.view.layoutIfNeeded()

        }) { _ in
            self.loadGettingStarted()
            UIView.animateWithDuration(0.5, animations: {
                self.pageControl.alpha = 1
                self.scrollView.alpha = 1
            })
        }
    }
    
    private func tutorialPages() -> [String] {
        return ["GettingStartedMapViewController", "GettingStartedNetworksViewController", "GettingStartedStopwatchViewController"];
    }
    
    private func loadGettingStarted() {
        let identifiers = self.tutorialPages()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let svWidth = CGRectGetWidth(self.scrollView.frame)

        var idx = 0
        for identifier in identifiers {
            let vc = storyboard.instantiateViewControllerWithIdentifier(identifier) as! UIViewController
            let view = vc.view
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            scrollView.addSubview(view)
            
            let centerXConstraint = NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: self.scrollView, attribute: .CenterX, multiplier: 1, constant: CGFloat(idx) * svWidth)
            let centerYConstraint = NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: self.scrollView, attribute: .CenterY, multiplier: 1, constant: 0)
            
            scrollView.addConstraints([centerXConstraint, centerYConstraint])
            
            idx++
        }
        
        self.scrollView.contentSize = CGSizeMake(svWidth * CGFloat(idx), self.scrollView.contentSize.height)
    }
    
    @IBAction func thanksPressed(sender: AnyObject) {
        performSegueWithIdentifier("Map", sender: nil)
        UserSettings.sharedInstance().setDisplayedGettingStarted(true)
    }
    
    /// MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let svWidth = CGRectGetWidth(self.scrollView.frame)
        
        pageControl.currentPage = Int(offsetX / svWidth)
        
        /// Enable and show thanks buton
        if thanksButton.enabled == false && (self.pageControl.currentPage + 1) == self.tutorialPages().count {
            thanksButton.enabled = true
            UIView.animateWithDuration(0.25, animations: {
                self.thanksButton.alpha = 1
            })
        }
    }
}
