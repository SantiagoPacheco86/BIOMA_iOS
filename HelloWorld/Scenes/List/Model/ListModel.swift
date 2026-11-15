//
//  ListModel.swift
//  HelloWorldJdJVL
//
//  Created by José De Jesús Vega López on 21/04/26.
//

// ⚠️ TEMPORAL: ejemplo de clase con PokeAPI.
// Este archivo se adaptará a la API definitiva de BIOMA.

import Foundation

struct ListModel {
    var pokemons: [GetPokemon.Pokemon] = []
    
    enum GetPokemons {
        case success(list: [GetPokemon.Pokemon])
        case failure(error: Error)
    }
}
