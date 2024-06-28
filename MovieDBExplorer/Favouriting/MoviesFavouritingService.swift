//
//  MoviesFavouritingService.swift
//  MovieDBExplorer
//
//  Created by Tomek on 27/06/2024.
//

import Foundation
import Combine

///
/// NOTE: to limit scope of the app, favouriting is done in a sync way (using UserDefault)
///
final class MoviesFavouritingService: Favouriting {
    
    enum Constant {
        static let key = "favoriteVideosIdsKey"
    }
    
    var changesPublisher: AnyPublisher<Movie.Id, Never> { changesSubject.eraseToAnyPublisher() }

    private let defaults = UserDefaults.standard
    private(set) var favouriteIds = Set<Movie.Id>()
    private let changesSubject = PassthroughSubject<Movie.Id, Never>()
    
    // TODO: inject UserDefaults as protocol; make it testable
    init() {
        let ids = defaults.array(forKey: Constant.key) as? [Int]
        self.favouriteIds = Set(ids ?? [])
    }
    
    func addToFavourite(id: Movie.Id) {
        favouriteIds.insert(id)
        storeChanges()
        changesSubject.send(id)
    }
    
    func removeFromFavourite(id: Int) {
        favouriteIds.remove(id)
        storeChanges()
        changesSubject.send(id)
    }
    
    private func storeChanges() {
        defaults.setValue(Array(favouriteIds), forKey: Constant.key)
    }
    
}
