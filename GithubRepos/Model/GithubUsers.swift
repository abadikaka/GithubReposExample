//
//  GithubUsers.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation

/**
 * @discussion List Github Users Information
 */
class GithubUsers: NSObject {
    var users: [User] = []
    var favouriteChannel: [Int] = []
    var arrayResponse: [[String: AnyObject]] = [[:]]
    
    init(array: [[String: AnyObject]]){
        arrayResponse = array
        var counter: Int = 0
        while counter < array.count {
            let githubUser = User(dictionary: array[counter])
            users.append(githubUser)
            counter = counter + 1
        }
    }
    
    /**
     * @discussion function for get fav users from db to be marked in the list
     */
    func getFavouriteChannels()->[Int]{
        let filteredUsers = users.filter({return $0.markedAsFavorite == true})
        return filteredUsers.map({return $0.id})
    }
    
    /**
     * @discussion function for setup fav users from db to be marked in the channel
     * @param channelIds which is the array of channel id from db
     */
    func setupFavouriteChannel(channelIds: [Int]){
        for data in users {
            for id in channelIds {
                if data.id == id  && id <= users.count{
                    users[id-1].addToFavourite()
                }
            }
        }
    }
    
    /**
     * @discussion function for add new github user to user preferences
     * @param id which is the id of git user
     */
    func addNewChannelToFavourite(id: Int) {
        favouriteChannel.append(id)
    }
    
    /**
     * @discussion function for delete github user from user preferences
     * @param id which is the id of git user
     */
    func deleteNewChannelFromFavourite(id: Int) {
        favouriteChannel = favouriteChannel.filter { $0 != id }
    }
    
}
