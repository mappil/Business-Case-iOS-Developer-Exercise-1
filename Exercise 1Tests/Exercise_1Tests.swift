//
//  Exercise_1Tests.swift
//  Exercise 1Tests
//
//  Created by allegretti massimiliano on 13/04/24.
//

import XCTest
@testable import Exercise_1

final class Exercise_1Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: Mapper
    
    func testDecodePokemonModel() throws {
        let data = try self.getJSON(fileName: "pokemon")
        let decoder = JSONDecoder()
        let pokemonModel: PokemonModel = try decoder.decode(PokemonModel.self, from: data)
        XCTAssertTrue(pokemonModel.count == 1302)
        XCTAssertTrue(pokemonModel.next?.absoluteString == "https://pokeapi.co/api/v2/pokemon?offset=20&limit=20")
        XCTAssertTrue(pokemonModel.previous == nil)
        XCTAssertTrue(pokemonModel.pokemon?.count == 20)
        XCTAssertTrue(pokemonModel.pokemon?.first?.name == "bulbasaur")
        XCTAssertTrue(pokemonModel.pokemon?.first?.url.absoluteString == "https://pokeapi.co/api/v2/pokemon/1/")
    }
    
    func testDecodePokemonDetail() throws {
        let data = try self.getJSON(fileName: "bulbasaur")
        let decoder = JSONDecoder()
        let pokemon: PokemonDetail = try decoder.decode(PokemonDetail.self, from: data)
        XCTAssertTrue(pokemon.name == "bulbasaur")
        XCTAssertTrue(pokemon.id == 1)
        XCTAssertTrue(pokemon.defaultImageURL?.absoluteString == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
    }
    
    // MARK: Api
    
    func testApiFetchStart() throws {
        let viewModel = HomeViewModel()
        
        let expectation = self.expectation(description: "Fetch start")
        
        viewModel.fetch(type: .start) { result in
            switch result {
            case .success:
                XCTAssertNotNil(viewModel.model.data)
                XCTAssertNotNil(viewModel.model.data?.pokemon)
                XCTAssertTrue((viewModel.model.data?.pokemon?.count ?? 0) > 0)
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testApiFetchMore() throws {
        let viewModel = HomeViewModel()
        
        let expectation = self.expectation(description: "Fetch start")
        let expectation2 = self.expectation(description: "Fetch more")
        
        var pokemon: [Pokemon] = []
        
        viewModel.fetch(type: .start) { result in
            switch result {
            case .success:
                XCTAssertNotNil(viewModel.model.data)
                XCTAssertNotNil(viewModel.model.data?.pokemon)
                XCTAssertTrue((viewModel.model.data?.pokemon?.count ?? 0) > 0)
                pokemon = viewModel.model.data?.pokemon ?? []
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            
            
            viewModel.fetch(type: .more) { result in
                switch result {
                case .success:
                    XCTAssertNotNil(viewModel.model.data)
                    XCTAssertNotNil(viewModel.model.data?.pokemon)
                    XCTAssertTrue((viewModel.model.data?.pokemon?.count ?? 0) > 0)
                    XCTAssertTrue((viewModel.model.data?.pokemon?.count ?? 0) > pokemon.count)
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                }
                
                expectation2.fulfill()
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation, expectation2], timeout: 10.0)
    }
    
    
    func testApiSearchPokemon() throws {
        let viewModel = HomeViewModel()
        
        let expectation = self.expectation(description: "Fetch pokemon")
        let pokemonName = "Bulbasaur"
        viewModel.searchPokemon(name: pokemonName) { result in
            switch result {
            case .success:
                XCTAssertNotNil(viewModel.model.data)
                XCTAssertNotNil(viewModel.model.data?.pokemon)
                XCTAssertTrue(viewModel.model.data?.pokemon?.first?.name.lowercased() == pokemonName.lowercased())
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}

// MARK: Utils

extension Exercise_1Tests {
    
    func getJSON(fileName: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw JSONError.notFound(fileName)
        }
        return try Data(contentsOf: url)
    }
    
    enum JSONError: Error {
        case notFound(String)
    }
    
}
