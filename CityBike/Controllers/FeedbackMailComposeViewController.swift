//
//  FeedbackMailComposeViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackMailComposeViewController: MFMailComposeViewController, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
   
    class func presentInViewController(vc: UIViewController!) {
        if self.canSendMail() {
            let composer = FeedbackMailComposeViewController()
            composer.mailComposeDelegate = composer
            composer.setToRecipients(["mail+citybike@szulctomasz.com"])
            composer.setSubject("In-App Support")
            composer.setMessageBody(self.generateMessageBody(), isHTML: false)
            vc.presentViewController(composer, animated: true, completion: nil)
        }
    }
    
    private class func generateMessageBody() -> String {
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
        UIAlertView(title: I18N.localizedString("feedback"), message: error, delegate: nil, cancelButtonTitle: I18N.localizedString("ok")).show()
    }
    
    /// MARK: MFMAilComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if result.value == MFMailComposeResultFailed.value {
            showFailure(error.localizedDescription)
            
        } else {
            controller.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
