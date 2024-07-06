//
//  MoviesListDiffableDataSource.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import UIKit
import Combine
import CombineSchedulers


struct MovieItemViewModel {
    let id: Int
    let title: String
    let imageUrl: URL?
    let isFavourite: Bool
    
    let toogleFavourite: () -> ()
}


final class MoviesListViewModel {
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Movie.Id>
    
    enum Error: Swift.Error {
        case networking
    }
    
    // TODO: add localizations for title
    let title = "Playing Now"
    
    // TODO: add view state handling in the view
    @Published private(set) var viewState: ViewState = .empty
    @Published private(set) var snapshot: DataSourceSnapshot = .emptySection
    
    private var viewModels = [Movie.Id: MovieItemViewModel]()
    
    private let moviesProvider: AnyPublisher<MoviesResponse, Swift.Error>
    private let coordinator: MoviesListCoordinating
    private let moviesFavouriting: any Favouriting<Movie.Id>
    
    private var cancellables = [AnyCancellable]()
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        moviesProvider: AnyPublisher<MoviesResponse, Swift.Error>,
        coordinator: MoviesListCoordinating,
        moviesFavouriting: any Favouriting<Movie.Id>,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.moviesProvider = moviesProvider
        self.coordinator = coordinator
        self.moviesFavouriting = moviesFavouriting
        self.mainScheduler = mainScheduler
        handleFavouritingChanges()
    }
    
    
    // MARK: -
    
    func onViewWillAppear() {
        loadMovies()
    }
    
    
    func movieItem(with id: Movie.Id) -> MovieItemViewModel? {
        viewModels[id]
    }
    
    
    func tappedItem(movieId: Movie.Id) {
        guard let movie = viewModels[movieId] else { return }
        coordinator.onEnteringMovie(movieId: movieId, title: movie.title)
    }
    
    
    // MARK: -
    
    private func loadMoviesIfNeeded() {
        guard viewState != .loading else { return }
        loadMovies()
    }
    
    private func loadMovies() {
        viewState = .loading
        let favouriteIds = moviesFavouriting.favouriteIds
        
        let viewModelsPublisher = moviesProvider
            .map(\.results)
            .map { ($0, favouriteIds) }
            .map(viewModels(from:favouriteIds:))
            .mapError { _ in Error.networking }
            .share()
        
        let getViewModelsPublisher = viewModelsPublisher
            .map { output in
               let dictionary = Dictionary(uniqueKeysWithValues: output.map { ($0.id, $0) })
                return dictionary
            }
        
        let getSnapshotPublisher = viewModelsPublisher
            .map(snapshot(from:))
        
        Publishers.Zip(getViewModelsPublisher, getSnapshotPublisher)
            .receive(on: mainScheduler)
            .sink(receiveCompletion: handle(completion:), receiveValue: handle(viewModels:snapshot:))
            .store(in: &cancellables)
    }
    
    
    private func snapshot(from viewModels: [MovieItemViewModel]) -> DataSourceSnapshot {
        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModels.map(\.id))
        return snapshot
    }
    
    
    private func handle(viewModels: [Movie.Id: MovieItemViewModel], snapshot: DataSourceSnapshot) {
        self.viewModels = viewModels
        viewState = .loaded
        self.snapshot = snapshot
    }
    

    
    private func handle(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            viewState = .loaded
        case .failure:
            viewState = .error
        }
    }
    
    
    private func viewModels(from models: [Movie], favouriteIds: Set<Int>) -> [MovieItemViewModel] {
        models.map {
            MovieItemViewModel(
                movie: $0,
                toogleFavourite: self.toggleFavourite(movieId:),
                isFavourite: favouriteIds.contains($0.id)
            )
        }
    }
    
    
    private func toggleFavourite(movieId: Movie.Id) {
        guard let viewModel = viewModels[movieId] else { return }
        reconfigure(
            viewModel: viewModel,
            isFavourite: moviesFavouriting.toogle(id: movieId)
        )
    }
    
    private func reconfigure(viewModel: MovieItemViewModel, isFavourite: Bool) {
        viewModels[viewModel.id] = .init(
            viewModel: viewModel,
            isFavourite: isFavourite
        )
        
        var snapshot = self.snapshot
        snapshot.reconfigureItems([viewModel.id])
        self.snapshot = snapshot
    }
    
    private func handleFavouritingChanges() {
        moviesFavouriting.changesPublisher
            .receive(on: mainScheduler)
            .sink(receiveValue: reconfigureIsFavourite)
            .store(in: &cancellables)
    }
    
    private func reconfigureIsFavourite(movieId: Movie.Id) {
        guard let viewModel = viewModels[movieId] else { return }
        reconfigure(
            viewModel: viewModel,
            isFavourite: moviesFavouriting.isFavourite(id: movieId)
        )
    }
    
}


private extension MovieItemViewModel {
    
    init(movie: Movie, toogleFavourite: @escaping (Movie.Id) -> (), isFavourite: Bool) {
        self.id = movie.id
        self.title = movie.title
        self.imageUrl = movie.posterPath.flatMap { MovieDBEndpoint.imageUrl(path:$0) }
        self.isFavourite = isFavourite
        self.toogleFavourite = { toogleFavourite(movie.id) }
    }
    
    init(viewModel: MovieItemViewModel, isFavourite: Bool) {
        self.id = viewModel.id
        self.title = viewModel.title
        self.imageUrl = viewModel.imageUrl
        self.toogleFavourite = viewModel.toogleFavourite
        self.isFavourite = isFavourite
    }
}


