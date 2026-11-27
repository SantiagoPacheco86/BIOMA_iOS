//
//  ApiRequestModel.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

import Foundation

// MARK: - ApiRequestModel
//
// Descripción completa de una petición a la API: qué ruta se consulta, con qué
// método HTTP, si lleva token, cómo viajan los parámetros y cuáles son.
// Los repositorios construyen este modelo y ApiService lo convierte en una
// URLRequest.
struct ApiRequestModel {
    let endpoint: Endpoint
    let method: HTTPMethod
    let header: Header
    let encoding: Encoding
    let parameters: ParameterType?
}
