//
//  HomeViewModel.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import UIKit

class HomeViewModel {
    var model = HomeModel()
    
    private static let baseURLString = "https://pokeapi.co/api/v2/"
    private let baseURL = URL(string: baseURLString)!
    private let pokemonEndpoint = "pokemon/"
    
    private var isFetchingMore = false
    
    /// - Description: The function adds Pokémon to the model's list
    /// [Pokémon API](https://pokeapi.co/docs/v2#pokemon) returns a list of Pokémon names which through the pokemon's id the same API is called to obtain the details of the Pokemon
    /// - Error: In case of error the function is completed with the result of failure and the related error
    func fetch(type: HomeViewModel.FetchType,
               completion: @escaping (Result<(), Error>) -> ()) {
        var url: URL?
        
        switch type {
        case .start:
            url = URL(string: "\(HomeViewModel.baseURLString)\(pokemonEndpoint)") // Use the "pokemon/" endpoint
        case .more:
            guard let nextURL = model.data?.next else {
                completion(.failure(HomeError.emptyData))
                return
            }
            url = nextURL
        }
        
        guard let taskURL = url else {
            completion(.failure(HomeError.invalidURL))
            return
        }
        
        
        guard !isFetchingMore else {
            completion(.failure(HomeError.concurrency))
            return
        }
        
        isFetchingMore = true
        self.fetchData(from:  taskURL) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let pokemonModel: PokemonModel = try decoder.decode(PokemonModel.self, from: data)
                    
                    switch type {
                    case .start:
                        self?.model.data = pokemonModel
                    case .more:
                        self?.model.append(pokemonModel)
                    }
                    
                    self?.fetchPokemonDetails(for: self?.model.data?.pokemon ?? [], completion: { result in
                        completion(.success)
                    })
                    
                } catch {
                    completion(.failure(error))
                }
                
                
            case .failure(let error):
                completion(.failure(error))
            }
            self?.isFetchingMore = false
        }
    }
    
    /// - Description: The function searches for a Pokémon by its name and inserts it into the model
    /// [Pokémon API](https://pokeapi.co/docs/v2#pokemon) returns Pokémon detail through the pokemon's name
    /// - Error: In case of error the function is completed with the result of failure and the related error
    func searchPokemon(name: String,
                       completion: @escaping (Result<(), Error>) -> ()) {
        
        let url = URL(string: "\(HomeViewModel.baseURLString)\(pokemonEndpoint)\(name.lowercased())")
        
        guard let taskURL = url else {
            completion(.failure(HomeError.invalidURL))
            return
        }
        
        self.fetchData(from:  taskURL) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let detail = try decoder.decode(PokemonDetail.self, from: data)
                    
                    let pokemon = Pokemon(name: detail.name,
                                          url: taskURL,
                                          detail: detail)
                    let pokemonModel = PokemonModel(pokemon: pokemon)
                    self?.model.data = pokemonModel
                    completion(.success)
                    
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
                
            }
        }
    }
    
    /// - Description: The function obtains the details of a Pokémon through the URL obtained from the list
    /// [Pokémon API](https://pokeapi.co/docs/v2#pokemon) returns the Pokémon's detail through the Pokémon's id
    /// - Error: In case of error the function is completed with the result of failure and the related error
    func fetchPokemon(pokemon: Pokemon,
                      completion: @escaping (Result<PokemonDetail, Error>) -> ()) {
        self.fetchData(from:  pokemon.url) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let detail = try decoder.decode(PokemonDetail.self, from: data)
                    
                    completion(.success(detail))
                    
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func showGenericErrorAlert(from controller: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: NSLocalizedString("An error occurred. Check your internet connection and try again.", comment: ""),
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), 
                                         style: .cancel)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true)
    }
    
    func showItemNotFoundAlert(from controller: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("Item not found", comment: ""),
                                      message: NSLocalizedString("There is no Pokemon with this name. Check that you have written the name correctly.", comment: ""),
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
    
    // MARK: Private funcs
    
    private func fetchPokemonDetails(for pokemons: [Pokemon], completion: @escaping (Result<(), Error>) -> Void) {
        let dispatchQueue = DispatchQueue(label: "PokemonDetailQueue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        
        for pokemon in pokemons {
            dispatchGroup.enter()
            
            fetchPokemon(pokemon: pokemon) { result in
                switch result {
                case .success(let detail):
                    pokemon.setDetail(detail)
                case .failure:
                    break
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: dispatchQueue) {
            completion(.success(()))
        }
    }
}

// MARK: - Network call management
extension HomeViewModel {
    
    private func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        guard Reachability.isConnectedToNetwork() else {
            completion(.failure(HomeError.noInternetConnection))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(HomeError.emptyData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}

// MARK: - Error
extension HomeViewModel {
    enum HomeError: Error {
        case emptyData
        case invalidURL
        case concurrency
        case noInternetConnection
    }
}

// MARK: - Fetch Type
extension HomeViewModel {
    enum FetchType {
        case start
        case more
    }
}
