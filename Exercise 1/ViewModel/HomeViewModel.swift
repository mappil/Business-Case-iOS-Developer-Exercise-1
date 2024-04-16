//
//  HomeViewModel.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import UIKit
import Combine

class HomeViewModel: ObservableObject {
    var model = HomeModel()
    
    private static let baseURLString = "https://pokeapi.co/api/v2/"
    private let baseURL = URL(string: baseURLString)!
    private let pokemonEndpoint = "pokemon/"
    
    private var isFetchingMore = false
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Fetch Functions
    
    /// - Description: The function adds Pokémon to the model's list
    /// [Pokémon API](https://pokeapi.co/docs/v2#pokemon) returns a list of Pokémon names which through the pokemon's id the same API is called to obtain the details of the Pokemon
    /// - Error: In case of error the function is completed with the result of failure and the related error
    func fetch(type: FetchType) async throws -> Void {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            
            guard !isFetchingMore else {
                continuation.resume(throwing: NetworkError.concurrency)
                return
            }
            
            isFetchingMore = true
            
            fetchDataAndProcess(type: type)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        continuation.resume(returning: ())
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }
    
    /// - Description: The function searches for a Pokémon by its name and inserts it into the model
    /// [Pokémon API](https://pokeapi.co/docs/v2#pokemon) returns Pokémon detail through the pokemon's name
    /// - Error: In case of error the function is completed with the result of failure and the related error
    func searchPokemon(name: String) async throws -> Void {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            
            fetchSearchPokemon(name: name)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        continuation.resume(returning: ())
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }
    
    
    // MARK: - Private Functions
    
    /// - Description: The function obtains the details of a Pokémon through the URL obtained from the list
    /// [Pokémon API](https://pokeapi.co/docs/v2#pokemon) returns the Pokémon's detail through the Pokémon's id
    /// - Error: In case of error the function is completed with the result of failure and the related error
    private func fetchPokemon(pokemon: Pokemon) -> AnyPublisher<PokemonDetail, Error> {
        return fetchData(from: pokemon.url)
            .tryMap { data -> PokemonDetail in
                let decoder = JSONDecoder()
                return try decoder.decode(PokemonDetail.self, from: data)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchDataAndProcess(type: FetchType) -> AnyPublisher<(), Error> {
        guard let url = buildURL(for: type) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return fetchData(from: url)
            .flatMap { [weak self] data -> AnyPublisher<(), Error> in
                guard let self = self else {
                    return Fail(error: NetworkError.selfDeallocated).eraseToAnyPublisher()
                }
                
                do {
                    let decoder = JSONDecoder()
                    let pokemonModel: PokemonModel = try decoder.decode(PokemonModel.self, from: data)
                    
                    switch type {
                    case .start:
                        self.model.data = pokemonModel
                    case .more:
                        self.model.append(pokemonModel)
                    }
                    
                    return self.fetchPokemonDetails(for: self.model.data?.pokemon ?? [])
                } catch {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isFetchingMore = false
            })
            .eraseToAnyPublisher()
    }
    
    private func fetchSearchPokemon(name: String) -> AnyPublisher<Void, Error> {
        guard let url = buildURL(for: .start)?.appendingPathComponent(name.lowercased()) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return fetchData(from: url)
            .tryMap { data -> PokemonDetail in
                
                let decoder = JSONDecoder()
                return try decoder.decode(PokemonDetail.self, from: data)
            }
            .map { detail -> PokemonModel in
                let pokemon = Pokemon(name: detail.name, url: url, detail: detail)
                return PokemonModel(pokemon: pokemon)
            }
            .handleEvents(receiveOutput: { [weak self] pokemonModel in
                self?.model.data = pokemonModel
            })
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Functions
    
    private func buildURL(for type: FetchType) -> URL? {
        switch type {
        case .start:
            return URL(string: "\(HomeViewModel.baseURLString)\(pokemonEndpoint)")
        case .more:
            return model.data?.next
        }
    }
    
    private func fetchData(from url: URL) -> AnyPublisher<Data, Error> {
        guard Reachability.isConnectedToNetwork() else {
            return Fail(error: NetworkError.noInternetConnection).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { $0 as Error }
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    private func fetchPokemonDetails(for pokemons: [Pokemon]) -> AnyPublisher<(), Error> {
        return pokemons.publisher
            .flatMap { self.fetchPokemon(pokemon: $0) }
            .map { pokemonDetail -> Void in
                if let index = self.model.data?.pokemon?.firstIndex(where: { $0.name == pokemonDetail.name }) {
                    self.model.data?.pokemon?[index].setDetail(pokemonDetail)
                }
            }
            .collect()
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Error Handling
    
    func handleAPIError(error: Error, from controller: UIViewController) {
        if let homeError = error as? NetworkError {
            switch homeError {
            case .invalidURL:
                showGenericErrorAlert(from: controller)
            case .concurrency:
                // Handle concurrency error
                break
            case .noInternetConnection:
                showNoInternetConnectionAlert(from: controller)
            case .selfDeallocated:
                // Handle self deallocated error
                break
            default:
                showGenericErrorAlert(from: controller)
            }
        } else {
            // Handle other types of errors
            showGenericErrorAlert(from: controller)
        }
    }
    
    // MARK: - Alerts
    
    func showGenericErrorAlert(from controller: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: NSLocalizedString("An error occurred. Check your internet connection and try again.", comment: ""),
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                         style: .cancel)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true)
    }
    
    func showNoInternetConnectionAlert(from controller: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("No Internet Connection", comment: ""),
                                      message: NSLocalizedString("Please check your internet connection and try again.", comment: ""),
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""),
                                         style: .default)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showItemNotFoundAlert(from controller: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("Item not found", comment: ""),
                                      message: NSLocalizedString("There is no Pokemon with this name. Check that you have written the name correctly.", comment: ""),
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true)
    }
}

// MARK: - Search
extension HomeViewModel {
    
    func inSearchMode(_ searchController: UISearchController) -> Bool {
        let isActive = searchController.isActive
        let searchText = searchController.searchBar.text ?? ""
        
        return isActive && !searchText.isEmpty
    }
    
}

// MARK: - Fetch Type
extension HomeViewModel {
    enum FetchType {
        case start
        case more
    }
}

// MARK: - Error
enum NetworkError: Error {
    case emptyData
    case invalidURL
    case concurrency
    case noInternetConnection
    case selfDeallocated
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyData:
            return NSLocalizedString("Empty data received from the server.", comment: "")
        case .invalidURL:
            return NSLocalizedString("The URL provided is invalid.", comment: "")
        case .concurrency:
            return NSLocalizedString("Multiple network requests are not allowed concurrently.", comment: "")
        case .noInternetConnection:
            return NSLocalizedString("No internet connection available.", comment: "")
        case .selfDeallocated:
            return NSLocalizedString("The object has been deallocated.", comment: "")
        }
    }
}


