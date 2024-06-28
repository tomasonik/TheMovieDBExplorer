//
//  MoviesDetailsViewModel.swift
//  MovieDBExplorer
//
//  Created by Tomek on 26/06/2024.
//

import Foundation
import Combine

struct MovieAttributesViewModel: Equatable {
    
    struct Record: Equatable {
        let title: String
        let value: String
    }
    
    let posterUrl: URL?
    let details: [Record]
    
}

final class MovieDetailsViewModel {
    
    let title: String
    var isFavouritePublisher: AnyPublisher<Bool, Never> { isFavouriteSubject.eraseToAnyPublisher() }
    var viewStatePublisher: ViewStatePublisher { viewStateSubject.eraseToAnyPublisher() }
    var viewModelPublisher: AnyPublisher<MovieAttributesViewModel?, Never> { viewModelSubject.eraseToAnyPublisher() }
    
    private let isFavouriteSubject: CurrentValueSubject<Bool, Never>
    private let viewStateSubject = ViewStateSubject(.empty)
    private let viewModelSubject = CurrentValueSubject<MovieAttributesViewModel?, Never>(nil)
    private var cancellables = [AnyCancellable]()
    
    private let movieId: Movie.Id
    
    private let movieDetailsProvider: AnyPublisher<MovieDetails, Error>
    private let moviesFavouriting: any Favouriting<Movie.Id>
    
    init(
        title: String,
        movieId: Movie.Id,
        movieDetailsProvider: AnyPublisher<MovieDetails, Error>,
        moviesFavouriting: any Favouriting<Movie.Id>
    ) {
        self.title = title
        self.movieId = movieId
        self.movieDetailsProvider = movieDetailsProvider
        self.moviesFavouriting = moviesFavouriting
        isFavouriteSubject = .init(moviesFavouriting.isFavourite(id: movieId))
    }
    
    // MARK: -
    
    func onViewWillAppear() {
        loadIfNeeded()
    }
    
    func toogleFavourite() {
        isFavouriteSubject.value = moviesFavouriting.toogle(id: movieId)
    }
    
    // MARK: -
    
    private func loadIfNeeded() {
        guard [.empty, .error].contains(viewStateSubject.value) else { return }
        viewStateSubject.value = .loading
        movieDetailsProvider
            .map(\.attributesViewModel)
            .receive(on: DispatchSerialQueue.main)
            .sink(receiveCompletion: handle(completion:), receiveValue: handle(viewModel:))
            .store(in: &cancellables)
    }
    
    private func handle(viewModel: MovieAttributesViewModel) {
        viewModelSubject.value = viewModel
    }
    
    private func handle(completion: Subscribers.Completion<any Error>) {
        switch completion {
        case .failure:
            viewStateSubject.value = .error
        case .finished:
            viewStateSubject.value = .loaded
        }
    }

}


private extension MovieDetails {
    
    private static let separator = ", "
    
    var attributesViewModel: MovieAttributesViewModel {
        .init(
            posterUrl: backdropPath.flatMap { MovieDBEndpoint.imageUrl(path: $0) },
            details: details
        )
    }
    
    private var formattedProductionCountries: String? {
        productionCountries?.map(\.name).joined(separator: Self.separator)
    }
    
    private var formattedGenres: String? {
        genres?.map(\.name).joined(separator: Self.separator)
    }
    
    private var formattedRevenue: String? {
        // TODO: use number formatter
        revenue.map(String.init)?.appending(" $")
    }
    
    // TODO: add localizations for titles
    private var details: [MovieAttributesViewModel.Record] {
        [
            ("Original title", originalTitle),
            ("Genres", formattedGenres),
            ("Releasd on", releaseDate),
            ("Country", formattedProductionCountries),
            ("Revenue", formattedRevenue)
        ].map { param in
            MovieAttributesViewModel.Record.init(title: param.0, value: param.1 ?? "-")
        }
    }
    
}
