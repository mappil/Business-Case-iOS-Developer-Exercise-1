# Business-Case-iOS-Developer-Exercise-1
### Purpose of the exercise:
to evaluate code organisation and style, network management, ability to follow UI mockups.
### Request:
Develop an iOS application using UIKit that given a database of pokemon (provided by https://pokeapi.co) allows the user to browse it as a list and to search pokemon by name (ex: "Bulbasaur").
As a starting point you are provided with UI mockups of the pokemon list.
### Requirements:
* The list is paginated and shows a maximum of 20 items at a time. The maximum limit should not be changed, but you have to download the next page when you reach the bottom of the list.
* Usage of a Reactive Framework for any blocking functions, api or heavier calculations.
* Setup the project without using the Storyboard.
### Plus:
* Add some unit tests in order to check the business logic correctness
### Supplied material:
* [API documentation](https://pokeapi.co/docs/v2)
* [Mockup](https://drive.google.com/drive/folders/1C8P9c4HcKfm7cysV9oNWaq0U8vvJTDXI)


# Procedure:

## Technologies Used
- Swift
- UIKit
- URLSession
- JSON decoding
- MVVM (Model-View-ViewModel) design pattern
- Reachability for internet connection management

## Function Usage

### `func fetch(type: HomeViewModel.FetchType, completion: @escaping (Result<(), Error>) -> ())`
This function is used to retrieve a list of Pokémon from the Pokémon API. It takes the fetch type as input, which can be `.start` to initiate a new search or `.more` to load additional Pokémon from the existing list. The completion handler returns a `Result` object indicating whether the operation was completed successfully or if an error occurred.

### `func searchPokemon(name: String, completion: @escaping (Result<(), Error>) -> ())`
This function is used to search for a Pokémon by name in the Pokémon API. It takes the name of the Pokémon to search for as input and a completion handler that returns a `Result` object indicating whether the search was completed successfully or if an error occurred.

### `func fetchPokemon(pokemon: Pokemon, completion: @escaping (Result<PokemonDetail, Error>) -> ())`
This function is used to retrieve the details of a specific Pokémon from the Pokémon API. It takes a `Pokemon` object as input and a completion handler that returns a `Result` object containing the details of the Pokémon or an error, if one occurred.

## Unit Test:

### Test Decoding Pokemon Model
`func testDecodePokemonModel()`
This test ensures that the `PokemonModel` is decoded correctly from JSON data. It verifies various properties such as the count of Pokémon, the next and previous URLs, and details of the first Pokémon in the list.

### Test Decoding Pokemon Detail
`func testDecodePokemonDetail()`
This test verifies the decoding of `PokemonDetail` from JSON data. It ensures that properties like the Pokémon's name, ID, and default image URL are decoded correctly.

### Test API Fetch Start
`func testApiFetchStart()`
This test validates the functionality of fetching Pokémon data from the API when starting the app. It checks if the data model is populated with Pokémon and that there are Pokémon available in the list.

### Test API Fetch More
`func testApiFetchMore()`
This test confirms the ability to fetch additional Pokémon data from the API. It first fetches Pokémon data, then fetches more Pokémon, and ensures that the number of Pokémon retrieved is greater than before.

### Test API Search Pokemon
`func testApiSearchPokemon()`
This test verifies the search functionality for Pokémon by name in the API. It searches for a specific Pokémon by name, such as "Bulbasaur," and ensures that the correct Pokémon details are fetched.


## UI Test:

### Test Search Pokemon
`func testSearchPokemon()`
This UI test validates the search functionality for Pokémon within the app. It launches the app, enters a Pokémon name ("Jigglypuff") into the search field, and taps the search button. Then, it waits for the cell with the Pokémon name to appear in the list and verifies that the displayed Pokémon name matches the searched name.

