//
//  NotificationBarManager.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/5/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

/**
 * @discussion Class for Notif Bar
 */
class NotificationBarManager: NSObject {
    
    static let sharedInstance = NotificationBarManager()
    static var successCalledOnce = false
    static var failedCalledOnce = false
    let notifMessages = SwiftMessages()
    
    /**
     * @discussion function for showing the display network activity after got error
     */
    func showNotifBarError(errorType: NetworkError){
        notifMessages.defaultConfig.presentationStyle = .top
        let view = MessageView.viewFromNib(layout: .cardView)
        switch errorType {
        case .noInternet:
            view.configureTheme(.error)
            view.configureDropShadow()
            let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
            view.configureContent(title: "Warning", body: "No Internet Connection Detected !", iconText: iconText)
            view.button?.isHidden = true
            SwiftMessages.show(view: view)
            break
        default:
            view.configureTheme(.error)
            view.configureDropShadow()
            let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
            view.configureContent(title: "Warning", body: "No Internet Connection Detected !", iconText: iconText)
            view.button?.isHidden = true
            SwiftMessages.show(view: view)
            break
        }
    }
    
    /**
     * @discussion function for showing the display network activity after got success
     */
    func showNotifBarSuccess(){
        notifMessages.defaultConfig.presentationStyle = .top
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.configureDropShadow()
        let iconText = ["😍"].sm_random()!
        view.configureContent(title: "Success", body: "Good Internet Detected !", iconText: iconText)
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
}
