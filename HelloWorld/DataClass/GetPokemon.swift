//
//  GetPokemon.swift
//  HelloWorld
//

// ⚠️ TEMPORAL: ejemplo de clase con PokeAPI.
// Este archivo se adaptará a la API definitiva de BIOMA.

import Foundation

// MARK: - GetPokemon
//
// Representa la respuesta de https://pokeapi.co/api/v2/pokemon/
// Todas las propiedades son opcionales para que la decodificación no falle
// si la API omite un campo o lo envía como `null` (por ejemplo, `next` en la
// última página o `previous` en la primera).
struct GetPokemon: Codable {
    var count: Double?
    var next: String?
    var previous: String?
    var results: [Pokemon]?

    // MARK: - Pokemon

    struct Pokemon: Codable {
        var name: String?
        var url: String?
    }
}
