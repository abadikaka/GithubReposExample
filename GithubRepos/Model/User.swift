//
//  Users.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation
import UIKit

/**
 * @discussion User Detail Information
 * @discussion AbilityToFavourite conform to this protocol
 */
struct User: AbilityToFavourite {
    
    let login: String
    let id: Int
    let avatar: String
    let githubUrl: String
    let accountType: String
    let siteAdminStatus: String
    var markedAsFavorite: Bool
    
    mutating func addToFavourite() {
        markedAsFavorite = true
    }
    
    mutating func deleteFromFavourite() {
        markedAsFavorite = false
    }
    
    init(dictionary: [String: AnyObject]){
        id = dictionary["id"] as! Int
        login = dictionary["login"] as! String
        avatar = dictionary["avatar_url"] as! String
        githubUrl = dictionary["html_url"] as! String
        accountType = dictionary["type"] as! String
        let status = dictionary["site_admin"] as! Bool
        if status {
            siteAdminStatus = "Not Site Admin"
        }else{
            siteAdminStatus = "Valid Site Admin"
        }
        markedAsFavorite = false
    }
}


// MARK: - conform to protocol AbilityToSaveToDatabase
extension User: AbilityToSaveToDatabase {
    func saveToDatabase(key: String, object: AnyObject?) {
        if let object = object as? GithubUsers {
            object.addNewChannelToFavourite(id: id)
            DatabaseManager.sharedInstance.saveToDatabase(key: key, object: object as AnyObject, objectType: .users) { (response) in
                print("Git User Fav Saved")
            }
        }
    }
    
    func deleteFromDatabase(key: String, object: AnyObject?) {
        if let object = object as? GithubUsers {
            object.deleteNewChannelFromFavourite(id: id)
            DatabaseManager.sharedInstance.saveToDatabase(key: key, object: object as AnyObject, objectType: .users) { (response) in
                print("Git User Fav Deleted")
            }
        }
    }
    
    func updateToDatabase(key: String, object: AnyObject?) {
        
    }
    
    func retrieveFromDatabase(key: String) {
        DatabaseManager.sharedInstance.retrieveFromDatabase(key: key, objectType: .users) { (object, objectType) in
            switch objectType {
            case .users:
                let object = object as! Array<Int>
                print("RETRIEVE GIT USER FROM DATABASE", object)
            default: break
            }
        }
    }
}
