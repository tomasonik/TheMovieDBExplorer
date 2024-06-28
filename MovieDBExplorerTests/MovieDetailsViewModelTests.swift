//
//  MovieDetailsViewModelTests.swift
//  MovieDBExplorerTests
//
//  Created by Tomasz Horowski on 28/06/2024.
//

import XCTest
import Combine
@testable import MovieDBExplorer


final class MovieDetailsViewModelTests: XCTestCase {

    private var viewModel: MovieDetailsViewModel!
    private var mockMoviesFavoritingService: MockMoviesFavoritingService!
    private var stupMovieDetailsProvider: PassthroughSubject<MovieDetails, Error>!
    private var spyViewModel: AnyPublisher<MovieAttributesViewModel?, Never>!
    private var spyViewState: AnyPublisher<ViewState, Never>!
    private var spyIsFavourite: AnyPublisher<Bool, Never>!
    
    private let stubMovie = Movie.stub(id: 1, title: "stubbedTitle1")
    private let stubMovieDetails = MovieDetails.stub(
        id: 1,
        releaseDate: "stubbedReleaseDate",
        revenue: 100,
        productionCountries: [.init(name: "stubbedCountryName1"), .init(name: "stubbedCountryName2")],
        genres: [.init(name: "stubbedGenre1"), .init(name: "stubbedGenre2")],
        originalTitle: "stubbedOriginalTitle",
        backdropPath: "stubbedBackdropPath",
        posterPath: "stubbedPosterPath"
    )
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMoviesFavoritingService = MockMoviesFavoritingService()
        stupMovieDetailsProvider = PassthroughSubject<MovieDetails, Error>()
        
        stubViewModel()
        
        spyViewModel = viewModel.viewModelPublisher.eraseToAnyPublisher()
        spyViewState = viewModel.viewStatePublisher.eraseToAnyPublisher()
        spyIsFavourite = viewModel.isFavouritePublisher.eraseToAnyPublisher()
    }
    
    
    override func tearDownWithError() throws {
        viewModel = nil
        stupMovieDetailsProvider = nil
        mockMoviesFavoritingService = nil
        spyViewModel = nil
        spyViewState = nil
        spyIsFavourite = nil
        try super.tearDownWithError()
    }

    
    // MARK: -
  
    func testInit_ReturnsVideoTitle() {
        XCTAssertEqual(viewModel.title, stubMovie.title)
    }
    
    
    func testInit_ReturnsEmptyState() throws {
        XCTAssertEqual(try getOutput(from: spyViewState), .empty)
    }
    
    
    // MARK: -
    
    func testOnViewWillAppear_ReturnsLoadingViewState() throws {
        viewModel.onViewWillAppear()
        XCTAssertEqual(try getOutput(from: spyViewState), .loading)
    }
    
    
    func testOnViewWillAppear_Succeeds_ReturnsLoadedViewModel() throws {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(stubMovieDetails)
        stupMovieDetailsProvider.send(completion: .finished)

        XCTAssertEqual(try getNextOutput(from: spyViewState),  .loaded)
    }
    
    
    func testOnViewWillAppear_Fails_ReturnsError() throws {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(completion: .failure(StubError()))

        XCTAssertEqual(try getNextOutput(from: spyViewState),  .error)
    }
    
    // MARK: -
    
    func testOnViewWillAppear_Succeeds_ReturnsPosterUrl() throws {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(stubMovieDetails)
      
        XCTAssertEqual(
            try getNextOutput(from: spyViewModel)?.posterUrl,
            URL(string: "https://image.tmdb.org/t/p/originalstubbedBackdropPath")
        )
    }
    
    func testOnViewWillAppear_Succeeds_ReturnsMovieAttributes() throws {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(stubMovieDetails)
      
        // TODO: localize strings; do not hardcode localization in tests
        XCTAssertEqual(
            try getNextOutput(from: spyViewModel)?.details,
            [
                .init(title: "Original title", value: "stubbedOriginalTitle"),
                .init(title: "Genres", value: "stubbedGenre1, stubbedGenre2"),
                .init(title: "Released on", value: "stubbedReleaseDate"),
                .init(title: "Country", value: "stubbedCountryName1, stubbedCountryName2"),
                .init(title: "Revenue", value: "100 $"),

            ]
        )
    }
    
    
    // MARK: -
    
    func testIsFavourite_NotFavourite_ReturnsFalse() throws {
        XCTAssertFalse(try getOutput(from: viewModel.isFavouritePublisher))
    }
    
    
    func testIsFavourite_IsFavourite_ReturnsTrue() {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie.id]
        stubViewModel()
        XCTAssertTrue(try getOutput(from: viewModel.isFavouritePublisher))
    }
    
    
    // MARK: -
    
    func testToogleFavourite_NotFavourite_ToggleFavouirte() {
        viewModel.toogleFavourite()
        XCTAssertEqual(mockMoviesFavoritingService.spyAddToFavourite, [stubMovie.id])
    }
    
    
    func testToogleFavourite_NotFavourite_UpdatesFavourite() throws {
        viewModel.toogleFavourite()
        XCTAssertTrue(try getOutput(from: spyIsFavourite))
    }
    
    
    func testToogleFavourite_Favourite_ToggleFavouirte() {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie.id]
        stubViewModel()
        
        viewModel.toogleFavourite()
        
        XCTAssertEqual(mockMoviesFavoritingService.spyRemoveFromFavourite, [stubMovie.id])
    }
    
    
    func testToogleFavourite_Favourite_UpdatesFavourite() throws {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie.id]
        stubViewModel()
        
        viewModel.toogleFavourite()
        
        XCTAssertFalse(try getOutput(from: spyIsFavourite))
    }
    
    
    // MARK: -
    
    private func stubViewModel() {
        viewModel = .init(
            title: stubMovie.title,
            movieId: stubMovie.id,
            movieDetailsProvider: stupMovieDetailsProvider.eraseToAnyPublisher(),
            moviesFavouriting: mockMoviesFavoritingService
        )
    }
    
    
}
