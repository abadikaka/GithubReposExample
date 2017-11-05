//
//  Config.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation

/**
 * @discussion All Base Setting goes here
 */
struct Config {
    
    // base URL for the application API
    static let baseURL = "https://api.github.com/"
    
    // Endpoint
    struct Endpoint {
        static let getUsers = Config.baseURL + "users?since="
    }
    
    // Endpoint Parameters
    struct Parameters {
        static var getUserPaginationNumber = 0
    }
    
    // Database Key
    struct DatabaseKey {
        static let favourite = "Favourite"
        static let githubResponses = "GithubResponses"
    }
    
    // Avoid initialization of this (it's just for namingspace purposes)
    private init() {}
}

