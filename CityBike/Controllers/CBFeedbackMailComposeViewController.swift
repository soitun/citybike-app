//
//  CBFeedbackMailComposeViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MessageUI

class CBFeedbackMailComposeViewController: MFMailComposeViewController, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
   
    class func presentInViewController(vc: UIViewController!) {
        if self.canSendMail() {
            let composer = CBFeedbackMailComposeViewController()
            composer.mailComposeDelegate = composer
            composer.setToRecipients([self.supportEmail()])
            composer.setSubject(self.messageSubject())
            composer.setMessageBody(self.messageBody(), isHTML: false)
            vc.presentViewController(composer, animated: true, completion: nil)
        }
    }
    
    private class func supportEmail() -> String {
        return "mail+citybike@szulctomasz.com"
    }
    
    private class func messageSubject() -> String {
        return "In-App Support"
    }
    
    private class func messageBody() -> String {
        var mutableString = NSMutableString()
        mutableString.appendString("System Details: \n")
        mutableString.appendFormat("Device: %@\n", UIDevice.currentDevice().modelName)
        mutableString.appendFormat("iOS: %@\n", UIDevice.currentDevice().systemVersion)
        mutableString.appendFormat("App: %@\n", NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String)
        mutableString.appendString("---------------------")
        mutableString.appendString("\n\n")
        
        return mutableString as String
    }
    
    private func showFailure(error: String) {
        let alertView = UIAlertView(title: NSLocalizedString("Feedback", comment: ""), message: error, delegate: nil, cancelButtonTitle: NSLocalizedString("Close", comment: ""))
        alertView.show()
    }
    
    /// MARK: MFMAilComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if result.value == MFMailComposeResultFailed.value {
            self.showFailure(error.localizedDescription)
            
        } else {
            controller.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
