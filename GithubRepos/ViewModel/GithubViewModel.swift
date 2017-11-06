//
//  GithubViewModel.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/5/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation
import RxSwift

/**
 * @discussion Protocol to callback send event to the View of GitHub Controller to detect an error
 */
protocol GithubViewModelDelegate: class {
    func errorDidChange(error: NetworkError?)
}

/**
 * @discussion Class for Home GitHub ViewModel
 */
class GithubViewModel: NSObject {
    
    // necesary variable will be used in this view model
    var disposeBag = DisposeBag() // this one for RxSwift memory management
    let favouriteChannelIds = Variable<[Int]>([])
    
    //var githubList = Variable<GithubUsers?>(nil)
    var githubList : GithubUsers?
    var fetchCompletionHandler: ((GithubUsers?)->Void)?
    
    
    // variable for current errorType
    var errorType: NetworkError? {
        didSet {
            delegate?.errorDidChange(error: errorType)
        }
    }
    
    // delegation for detect error change
    weak var delegate: GithubViewModelDelegate? {
        didSet {
            delegate?.errorDidChange(error: errorType)
        }
    }
    
    
    override init() {
        super.init()
        githubList = nil
        retrieveFromDatabase(key: Config.DatabaseKey.favourite)
    }
    
    /**
     * @discussion function for fetching Github Users from API with RxSwift but something went wrong
     */
    /*func fetchGithubList() {
        NetworkManager.sharedInstance.fetchUrl(request: .getUsers, customUrl: nil, { (object) in
            if let object = object {
                let githubList = object as! GithubUsers
                let newArrayOfUser = githubList.users
                print("Array of new user : ", newArrayOfUser)
                if self.githubList.value != nil {
                    self.githubList.value!.users += newArrayOfUser
                }else {
                    self.githubList.value = githubList
                }
                
                // mapping current channel with the favourite
                self.githubList.value?.setupFavouriteChannel(channelIds: self.favouriteChannelIds.value)
            }else{
                DispatchQueue.main.async(execute: {
                    self.retrieveFromDatabase(key: Config.DatabaseKey.githubResponses)
                })
            }
        })
    }*/
    
    
    /**
     * @discussion function for fetching Github Users from API
     */
    func fetchGithubListOldWay(completion: @escaping(GithubUsers?) -> Void){
        NetworkManager.sharedInstance.fetchUrl(request: .getUsers, customUrl: nil, { [unowned self] (object) in
            if let object = object as? GithubUsers {
                let githubList = object
                let newArrayOfUser = githubList.users
                if self.githubList != nil {
                    self.githubList!.users += newArrayOfUser
                    self.githubList!.arrayResponse += githubList.arrayResponse
                }else {
                    self.githubList = githubList
                }
                
                // mapping current channel with the favourite
                self.githubList!.setupFavouriteChannel(channelIds: self.favouriteChannelIds.value)
                
                self.saveToDatabase(key: Config.DatabaseKey.githubResponses, object: self.githubList!.arrayResponse as AnyObject)
                self.errorType = nil
                DispatchQueue.main.async(execute: {
                    completion(self.githubList!)
                })
            }else{
                if let object = object as? URLError {
                    self.errorType = NetworkManager.sharedInstance.checkErrorType(errorCode: object.code.rawValue)
                }
                
                // if fail load Database one time
                self.fetchCompletionHandler = completion
                if DatabaseManager.appFirstLaunch {
                    DatabaseManager.appFirstLaunch = false
                    DispatchQueue.main.async(execute: {
                        self.retrieveFromDatabase(key: Config.DatabaseKey.githubResponses)
                    })
                }else{
                    DispatchQueue.main.async(execute: {
                        completion(nil)
                    })
                }
            }
        })
    }
    
    /**
     * @discussion function for adding current Index Cell to fav
     * @param indexPath which is the index of current cell
     */
    func addCurentIndexToFavourite(indexPath: Int){
        guard let githubList = githubList else {
            return
        }
        githubList.users[indexPath].addToFavourite()
        githubList.users[indexPath].saveToDatabase(key: Config.DatabaseKey.favourite, object: githubList)
    }
    
    /**
     * @discussion function for delete current Index Cell to fav
     * @param indexPath which is the index of current cell
     */
    func deleteCurentIndexToFavourite(indexPath: Int){
        guard let githubList = githubList else {
            return
        }
        githubList.users[indexPath].deleteFromFavourite()
        githubList.users[indexPath].deleteFromDatabase(key: Config.DatabaseKey.favourite, object: githubList)
    }
    
    
}

// MARK: - AbilityToSaveToDatabase protocol
extension GithubViewModel: AbilityToSaveToDatabase{
    
    func saveToDatabase(key: String, object: AnyObject?) {
        DatabaseManager.sharedInstance.saveToDatabase(key: key, object: object, objectType: .githubUsers) { (response) in
            print("Github List Responses saved")
        }
    }
    
    func deleteFromDatabase(key: String, object: AnyObject?) {
        
    }
    
    func retrieveFromDatabase(key: String) {
        if key == Config.DatabaseKey.githubResponses {
            DatabaseManager.sharedInstance.retrieveFromDatabase(key: key, objectType: .githubUsers) { [unowned self] (object, objectType) in
                if let object = object {
                    self.githubList = GithubUsers(array: object as! [[String: AnyObject]])
                    print("GithubResponses retrieved : ", self.githubList!.users.count)
                    // mapping current channel with the favourite
                    self.githubList!.setupFavouriteChannel(channelIds: self.favouriteChannelIds.value)
                    self.fetchCompletionHandler!(self.githubList!)
                }else{
                    self.fetchCompletionHandler!(nil)
                }
            }
        }else{
            DatabaseManager.sharedInstance.retrieveFromDatabase(key: key, objectType: .users) { (object, objectType) in
                if let object = object {
                    self.favouriteChannelIds.value = object as! Array<Int>
                    print("FAV RETRIEVED : ", self.favouriteChannelIds.value)
                }
            }
        }
    }
    
    func updateToDatabase(key: String, object: AnyObject?) {
        
    }
}

