//
//  HomeProtocol.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation

/**
 * @discussion Favorite Abilities protocol which defines the function for fav
 */
protocol AbilityToFavourite {
    mutating func addToFavourite()
    mutating func deleteFromFavourite()
}

