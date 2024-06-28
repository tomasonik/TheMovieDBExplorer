# TheMovieDBExplorer [WIP]
Demo of testable MVVM-C architecture in Swift/Combine/UIKit

![](https://github.com/tomasonik/TheMovieDBExplorer/blob/main/app_overview.gif)

## Scope
- list of movies screen - /movie/now_playing - no pagination
- movie details - /movie/{id} - with loading state
- persistent favouriting
- UnitTests (coverage is limited)

## Requirements
- iOS 15.0 (tested on iOS 15.5, iOS 18)
- Xcode 15.4
- API: [TheMovieDB](https://developer.themoviedb.org/docs/getting-started) - API key is required

## Dependencies (SPM)
- [SDWebImage](https://github.com/SDWebImage/SDWebImage)
