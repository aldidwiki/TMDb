# TMDb

TMDb is a SwiftUI iOS application for browsing movies, TV shows, and people from The Movie Database (TMDb). The app includes search, detail screens, favorite management, and a clean modular architecture built for iOS.

## Features

- Browse popular and latest movies
- Explore TV shows and episodes
- View detailed information for movies, TV shows, and cast members
- Search content by keyword
- Save favorite items locally
- Native iOS interface built with SwiftUI
- Clean architecture using repositories, use cases, and coordinators-like routing layers

## Screenshots

<div align="center">

![Movie list screen](screenshots/movie_list_screen.png)

![TV list screen](screenshots/tv_list_screen.png)

![Favorite list screen](screenshots/favorite_list_screen.png)

![Search result screen](screenshots/search_result_screen.png)

![TV detail screen](screenshots/tv_detail_screen.png)

![Seasons list screen](screenshots/seasons_list_screen.png)

![Episodes list screen](screenshots/episodes_list_screen.png)

![Person detail screen](screenshots/person_detail_screen.png)

</div>

## Tech Stack

- SwiftUI
- Swift
- TMDb API
- Alamofire
- SwiftData

## Project Structure

```text
TMDb/
├── App/
│   ├── TMDbApp.swift
│   ├── ContentView.swift
│   ├── SplashView.swift
│   └── LaunchScreen.storyboard
├── Core/
│   ├── CustomView/
│   ├── DI/
│   ├── Data/
│   ├── Domain/
│   └── Utils/
├── Module/
│   ├── Movie/
│   ├── TvShow/
│   ├── Search/
│   ├── Favorite/
│   ├── Person/
│   └── Detail/
├── Assets.xcassets/
├── Info.plist
├── .swiftlint.yml
├── .gitattributes
├── TMDb.xcodeproj/
└── README.md
```

## Getting Started

### Requirements

- Xcode 15 or later
- iOS 17+ recommended
- A macOS machine with Xcode installed

### Run the app

1. Clone the repository:

```bash
git clone https://github.com/aldidwiki/TMDb.git
```

2. Open `TMDb.xcodeproj` in Xcode.
3. Select a simulator or connected device.
4. Build and run the project.

## API Configuration

This project uses the TMDb API for movie and show data. The base configuration is located in:

- `TMDb/Core/Utils/API.swift`

The app currently includes an authorization token in the project. If the token expires or you want to use your own TMDb API access, update the `headers` or authentication logic in that file.

## Notes

- The project follows a modular SwiftUI architecture with separate feature folders for movies, TV shows, search, favorites, and detail views.
- Favorite data is persisted locally using SwiftData.
- Assets and styling are organized under `Assets.xcassets` and custom reusable view components live under `Core/CustomView`.

## License

This project does not currently include a license file. If you plan to distribute or reuse it publicly, consider adding an appropriate license such as MIT.

## Contributing

Pull requests and improvements are welcome. If you want to extend or fix the app, consider updating the relevant feature module and validating the app in Xcode.
