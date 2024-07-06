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
    
    private var spyViewModels = [MovieAttributesViewModel?]()
    private var spyViewStates = [ViewState]()
    private var spyIsFavourite = [Bool]()

    private var cancellables = [AnyCancellable]()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMoviesFavoritingService = MockMoviesFavoritingService()
        stupMovieDetailsProvider = PassthroughSubject<MovieDetails, Error>()
        
        stubViewModel()
    }
    
    
    override func tearDownWithError() throws {
        viewModel = nil
        stupMovieDetailsProvider = nil
        mockMoviesFavoritingService = nil
        spyViewModels = []
        spyViewStates = []
        spyIsFavourite = []
        cancellables = []
        try super.tearDownWithError()
    }

    
    // MARK: -
  
    func testInit_ReturnsVideoTitle() {
        XCTAssertEqual(viewModel.title, stubMovie.title)
    }
    
    
    func testInit_ReturnsEmptyState() {
        XCTAssertEqual(spyViewStates, [.empty])
    }
    
    
    // MARK: -
    
    func testOnViewWillAppear_ReturnsLoadingViewState() {
        viewModel.onViewWillAppear()
        XCTAssertEqual(spyViewStates.last, .loading)
    }
    
    
    func testOnViewWillAppear_Succeeds_ReturnsLoadedViewModel() {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(stubMovieDetails)
        stupMovieDetailsProvider.send(completion: .finished)

        XCTAssertEqual(spyViewStates.last,  .loaded)
    }
    
    
    func testOnViewWillAppear_Fails_ReturnsError() {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(completion: .failure(StubError()))

        XCTAssertEqual(spyViewStates.last,  .error)
    }
    
    // MARK: -
    
    func testOnViewWillAppear_Succeeds_ReturnsPosterUrl() {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(stubMovieDetails)
      
        XCTAssertEqual(
            spyViewModels.last??.posterUrl,
            URL(string: "https://image.tmdb.org/t/p/originalstubbedBackdropPath")
        )
    }
    
    func testOnViewWillAppear_Succeeds_ReturnsMovieAttributes() {
        viewModel.onViewWillAppear()
        
        stupMovieDetailsProvider.send(stubMovieDetails)
        stupMovieDetailsProvider.send(completion: .finished)

        // TODO: localize strings; do not hardcode localization in tests
        XCTAssertEqual(
            spyViewModels.last??.details,
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
    
    func testIsFavourite_NotFavourite_ReturnsFalse() {
        XCTAssert(spyIsFavourite.last == false)
    }
    
    
    func testIsFavourite_IsFavourite_ReturnsTrue() {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie.id]
        stubViewModel()
        XCTAssertEqual(spyIsFavourite, [true])
    }
    
    
    // MARK: -
    
    func testToogleFavourite_NotFavourite_ToggleFavouirte() {
        viewModel.toogleFavourite()
        XCTAssertEqual(mockMoviesFavoritingService.spyAddToFavourite, [stubMovie.id])
    }
    
    
    func testToogleFavourite_NotFavourite_UpdatesFavourite() {
        viewModel.toogleFavourite()
        XCTAssertEqual(spyIsFavourite.last, true)
    }
    
    
    func testToogleFavourite_Favourite_ToggleFavouirte() {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie.id]
        stubViewModel()
        
        viewModel.toogleFavourite()
        
        XCTAssertEqual(mockMoviesFavoritingService.spyRemoveFromFavourite, [stubMovie.id])
    }
    
    
    func testToogleFavourite_Favourite_UpdatesFavourite() {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie.id]
        stubViewModel()
        
        viewModel.toogleFavourite()
        
        XCTAssertEqual(spyIsFavourite.last, false)
    }
    
    
    // MARK: -
    
    private func stubViewModel() {
        viewModel = .init(
            title: stubMovie.title,
            movieId: stubMovie.id,
            movieDetailsProvider: stupMovieDetailsProvider.eraseToAnyPublisher(),
            moviesFavouriting: mockMoviesFavoritingService,
            mainScheduler: .immediate
        )
        
        spyViewModels = []
        spyViewStates = []
        spyIsFavourite = []
        
        viewModel.$viewModel
            .append(to: \.spyViewModels, on: self)
            .store(in: &cancellables)
        viewModel.$viewState
            .append(to: \.spyViewStates, on: self)
            .store(in: &cancellables)
        viewModel.$isFavourite
            .append(to: \.spyIsFavourite, on: self)
            .store(in: &cancellables)
    }
    
    
}
