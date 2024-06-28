//
//  MoviesListDiffableDataSource.swift
//  MovieDBExplorer
//
//  Created by Tomek on 26/06/2024.
//

import Foundation
import UIKit
import Combine

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
    var snapshotPublisher: AnyPublisher<DataSourceSnapshot, Never> { snapshotSubject.eraseToAnyPublisher() }
    
    // TODO: add view state handling in the view
    private let viewStateSubject = ViewStateSubject(.empty)
    private let snapshotSubject = PassthroughSubject<DataSourceSnapshot, Never>()
    
    private var viewModels = [Movie.Id: MovieItemViewModel]()
    private var snapshot: DataSourceSnapshot = .emptySection
    
    private let moviesProvider: AnyPublisher<MoviesResponse, Swift.Error>
    private let coordinator: MoviesListCoordinating
    private let moviesFavouriting: any Favouriting<Movie.Id>
    
    private var cancellables = [AnyCancellable]()

    
    init(
        moviesProvider: AnyPublisher<MoviesResponse, Swift.Error>,
        coordinator: MoviesListCoordinating,
        moviesFavouriting: any Favouriting<Movie.Id>
    ) {
        self.moviesProvider = moviesProvider
        self.coordinator = coordinator
        self.moviesFavouriting = moviesFavouriting
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
        guard viewStateSubject.value != .loading else { return }
        loadMovies()
    }
    
    private func loadMovies() {
        viewStateSubject.value = .loading
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
            .receive(on: DispatchQueue.main)
            .print()
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
        viewStateSubject.value = .loaded
        self.snapshot = snapshot
        snapshotSubject.send(snapshot)
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
    
    private func handle(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            viewStateSubject.value = .loaded
        case .failure:
            viewStateSubject.value = .error
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
        snapshotSubject.send(snapshot)
    }
    
    private func handleFavouritingChanges() {
        moviesFavouriting.changesPublisher
            .receive(on: DispatchSerialQueue.main)
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


