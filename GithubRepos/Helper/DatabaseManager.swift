//
//  DatabaseManager.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation

/**
 * @discussion enum for identify the object type
 */
enum ObjectType {
    case githubUsers
    case users
    case none
}

/**
 * @discussion protocol for defining db duties
 * @param key as the key for save into db
 * @param object as any object
 * @param objectType for defining the object type
 * @param completion as String
 */
protocol DatabaseDuty {
    func saveToDatabase(key: String, object: AnyObject?, objectType: ObjectType, completion: @escaping (String) -> Void)
    func deleteFromDatabase(key: String, object: AnyObject?, objectType: ObjectType,completion: @escaping (String) -> Void)
    func retrieveFromDatabase(key: String, objectType: ObjectType,completion: @escaping (AnyObject?, ObjectType) -> Void)
    func updateToDatabase(key: String, object: AnyObject?, objectType: ObjectType, completion: @escaping (String) -> Void)
}

/**
 * @discussion protocol for defining which class has db ability
 * @param key as the key to be saved into db
 * @param object as any object
 */
protocol AbilityToSaveToDatabase {
    func saveToDatabase(key: String, object: AnyObject?)
    func deleteFromDatabase(key: String, object: AnyObject?)
    func retrieveFromDatabase(key: String)
    func updateToDatabase(key: String, object: AnyObject?)
}

/**
 * @discussion Class for Database Manager -- Singleton and conform to Database Duty protocol
 */
class DatabaseManager: NSObject, DatabaseDuty {
    
    static let sharedInstance = DatabaseManager()
    static var appFirstLaunch = true
    
    func saveToDatabase(key: String, object: AnyObject?, objectType: ObjectType, completion: @escaping (String) -> Void) {
        switch objectType {
        case .users:
            if let object = object  {
                let githubUsers = object as! GithubUsers
                let defaults = UserDefaults.standard
                let favouriteChannels = githubUsers.getFavouriteChannels()
                defaults.set(favouriteChannels, forKey: key)
                defaults.synchronize()
                print("DONE UPDATE TO DATABASE", favouriteChannels)
                completion("success")
            }
        case .githubUsers:
            if let object = object  {
                let defaults = UserDefaults.standard
                let testObj = object as! [[String: AnyObject]]
                defaults.set(object as Any, forKey: key)
                defaults.synchronize()
                print("DONE UPDATE TO DATABASE", testObj.count)
                completion("success")
            }
        default:
            break
        }
    }
    
    func retrieveFromDatabase(key: String, objectType: ObjectType, completion: @escaping (AnyObject?, ObjectType) -> Void) {
        switch objectType {
        case .users:
            let defaults = UserDefaults.standard
            let array = defaults.array(forKey: key) as AnyObject?
            defaults.synchronize()
            print("DONE RETRIEVE FROM DATABASE")
            completion(array, objectType)
        case .githubUsers:
            let defaults = UserDefaults.standard
            let obj = defaults.object(forKey: key) ?? nil
            defaults.synchronize()
            if obj != nil {
                 completion(obj as AnyObject, objectType)
            }else{
                completion(nil, objectType)
            }
            
        default:
            break
        }
    }
    
    func updateToDatabase(key: String, object: AnyObject?, objectType: ObjectType, completion: @escaping (String) -> Void) {
        
    }
    
    func deleteFromDatabase(key: String, object: AnyObject?, objectType: ObjectType, completion: @escaping (String) -> Void) {
        
    }
}
