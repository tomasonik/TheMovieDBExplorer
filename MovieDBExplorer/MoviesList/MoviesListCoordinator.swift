//
//  MoviesListCoordinator.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import Foundation
import UIKit

protocol MoviesListCoordinating {
    
    func onEnteringMovie(movieId: Movie.Id, title: String)
    
}


final class MoviesListCoordinator: MoviesListCoordinating {
    
    private unowned let navigationRouting: NavigationRouting
    private let movieDetailsAssembler: MovieDetailsAssembling
    
    init(
        navigationRouting: NavigationRouting,
        movieDetailsAssembler: MovieDetailsAssembling = MovieDetailsAssembler()
    ){
        self.navigationRouting = navigationRouting
        self.movieDetailsAssembler = movieDetailsAssembler
    }
    
    func onEnteringMovie(movieId: Movie.Id, title: String) {
        navigationRouting.push(
            viewController: movieDetailsAssembler.assemble(movieId: movieId, title: title)
        )
    }
    
}

