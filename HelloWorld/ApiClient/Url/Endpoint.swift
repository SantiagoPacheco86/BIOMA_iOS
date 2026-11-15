//
//  Endpoint.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

import Foundation

// MARK: - Endpoint
//
// Rutas de la API de iNaturalist que utiliza BIOMA.
// A diferencia del ejemplo de clase, algunas rutas llevan parámetros
// (por ejemplo, el identificador de la especie), por eso cada caso
// construye su ruta en `path` en lugar de usar un valor fijo.
enum Endpoint {

    /// Búsqueda de especies por nombre (científico o común). Pública.
    case searchTaxa
    /// Detalle de una especie: familia, género, descripción y fotos. Pública.
    case taxonDetail(id: Int)
    /// Identificación de una especie a partir de una foto. Requiere token.
    case scoreImage

    var path: String {
        switch self {
        case .searchTaxa:            return "taxa/autocomplete"
        case .taxonDetail(let id):   return "taxa/\(id)"
        case .scoreImage:            return "computervision/score_image"
        }
    }
}
