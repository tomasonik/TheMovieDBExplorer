//
//  MoviesListAssembler.swift
//  MovieDBExplorer
//
//  Created by Tomek on 27/06/2024.
//

import Foundation
import UIKit

protocol MoviesListAssembling {
    
    func assemble() -> UIViewController
    
}

final class MoviesListAssembler: MoviesListAssembling {
    
    func assemble() -> UIViewController {
        let navigationController = UINavigationController()
        let viewModel = MoviesListViewModel(
            moviesProvider: MovieDBEndpoint.mowPlaying,
            coordinator: MoviesListCoordinator(navigationRouting: navigationController),
            moviesFavouriting: Dependencies.moviesFavouritingService
        )
        let moviesListViewController = MoviesListViewController(viewModel: viewModel)
        navigationController.pushViewController(moviesListViewController, animated: false)
        return navigationController
    }
    
}
