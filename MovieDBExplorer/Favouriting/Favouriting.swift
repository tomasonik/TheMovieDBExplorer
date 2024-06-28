//
//  FavouriteService.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 27/06/2024.
//

import Foundation
import Combine

///
/// NOTE: to limit scope of the app, favouriting is done is a sync way (using UserDefault)
/// However, this would be recommended to separate it from main thread as storing/reading favourite status may affect app performance
///
protocol Favouriting<Id> {

    associatedtype Id: Hashable
    
    func addToFavourite(id: Id)
    func removeFromFavourite(id: Id)

    var favouriteIds: Set<Id> { get }
    
    var changesPublisher: AnyPublisher<Id, Never> { get }
}

extension Favouriting {
    
    @discardableResult
    func toogle(id: Id) -> Bool {
        let isFavourite = !isFavourite(id: id)
        
        if isFavourite {
            addToFavourite(id: id)
        } else {
            removeFromFavourite(id: id)
        }
        
        return isFavourite
    }
    
    func isFavourite(id: Id) -> Bool {
        favouriteIds.contains(id)
    }
    
}
