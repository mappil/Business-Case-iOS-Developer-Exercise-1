//
//  HomeModel.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import Foundation

class HomeModel {
    
    var data: PokemonModel?
    
     func append(_ data: PokemonModel?) {
        guard let data = data else { return }
        self.data?.count = data.count
        self.data?.next = data.next
        self.data?.previous = data.previous
        self.data?.pokemon?.append(contentsOf: data.pokemon ?? [])

    }
}

struct PokemonModel: Decodable {
    var count: Int?
    var next: URL?
    var previous: URL?
    var pokemon: [Pokemon]?
    
    enum CodingKeys: CodingKey {
        case count
        case next
        case previous
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<PokemonModel.CodingKeys> = try decoder.container(keyedBy: PokemonModel.CodingKeys.self)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count)
        self.next = try container.decodeIfPresent(URL.self, forKey: .next)
        self.previous = try container.decodeIfPresent(URL.self, forKey: .previous)
        self.pokemon = try container.decodeIfPresent([Pokemon].self, forKey: .results)
    }
    
    init(pokemon: Pokemon) {
        self.count = nil
        self.next = nil
        self.pokemon = nil
        self.pokemon = [pokemon]
    }
    
}

class Pokemon: Decodable {
    let name: String
    let url: URL
    var detail: PokemonDetail?
    
    enum CodingKeys: CodingKey {
        case name
        case url
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(URL.self, forKey: .url)
        self.detail = nil
    }
    
    init(name: String, url: URL, detail: PokemonDetail?) {
        self.name = name
        self.url = url
        self.detail = detail
    }
    
    func setDetail(_ detail: PokemonDetail) {
        self.detail = detail
    }
}

struct PokemonDetail: Decodable {
    let id: Int
    let name: String
    let sprites: PokemonSprites?
    let types: [PokemonTypes]
    
    var defaultImageURL: URL? {
        sprites?.frontDefault
    }
    
    var officialArtworkImageURL: URL? {
        sprites?.other?.officialArtwork?.frontDefault
    }
    
    var homeImageURL: URL? {
        sprites?.other?.home?.frontDefault
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sprites
        case frontDefault = "front_default"
        case types
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PokemonDetail.CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.sprites = try container.decodeIfPresent(PokemonSprites.self, forKey: .sprites)
        self.types = try container.decode([PokemonTypes].self, forKey: .types)
    }
    
}

struct PokemonSprites: Decodable {
    let frontDefault: URL?
    let other: Other?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case other
    }
    
    struct Other: Decodable {
        let home: Sprite?
        let officialArtwork: Sprite?
        
        enum CodingKeys: String, CodingKey {
            case home
            case officialArtwork = "official-artwork"
        }
    }
    
    struct Sprite: Decodable {
        let frontDefault: URL?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}
struct PokemonTypes: Decodable {
    let slot: Int
    let type: Item
    
    struct Item: Decodable {
        let name: String
        let url: URL
    }
}
