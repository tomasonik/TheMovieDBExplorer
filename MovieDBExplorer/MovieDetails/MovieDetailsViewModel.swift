//
//  MoviesDetailsViewModel.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import Combine
import CombineSchedulers

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
    @Published private(set) var isFavourite: Bool
    @Published private(set) var viewState: ViewState = .empty
    @Published private(set) var viewModel: MovieAttributesViewModel?
        
    private let viewModelSubject = CurrentValueSubject<MovieAttributesViewModel?, Never>(nil)
    
    private var cancellables = [AnyCancellable]()
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    
    private let movieId: Movie.Id
    
    private let movieDetailsProvider: AnyPublisher<MovieDetails, Error>
    private let moviesFavouriting: any Favouriting<Movie.Id>
    
    init(
        title: String,
        movieId: Movie.Id,
        movieDetailsProvider: AnyPublisher<MovieDetails, Error>,
        moviesFavouriting: any Favouriting<Movie.Id>,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.title = title
        self.movieId = movieId
        self.movieDetailsProvider = movieDetailsProvider
        self.moviesFavouriting = moviesFavouriting
        self.mainScheduler = mainScheduler
        isFavourite = moviesFavouriting.isFavourite(id: movieId)
    }
    
    // MARK: -
    
    func onViewWillAppear() {
        loadIfNeeded()
    }
    
    func toogleFavourite() {
        isFavourite = moviesFavouriting.toogle(id: movieId)
    }
    
    // MARK: -
    
    private func loadIfNeeded() {
        guard [.empty, .error].contains(viewState) else { return }
        viewState = .loading

        movieDetailsProvider
            .map(\.attributesViewModel)
            .receive(on: mainScheduler)
            .sink(receiveCompletion: handle(completion:), receiveValue: handle(viewModel:))
            .store(in: &cancellables)
    }
    
    private func handle(viewModel: MovieAttributesViewModel) {
        self.viewModel = viewModel
    }
    
    private func handle(completion: Subscribers.Completion<any Error>) {
        switch completion {
        case .failure:
            viewState = .error
        case .finished:
            viewState = .loaded
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
            ("Released on", releaseDate),
            ("Country", formattedProductionCountries),
            ("Revenue", formattedRevenue)
        ].map { param in
            MovieAttributesViewModel.Record.init(title: param.0, value: param.1 ?? "-")
        }
    }
    
}
