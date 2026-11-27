//
//  Encoding.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

import Foundation

// MARK: - Encoding
//
// Forma en que viajan los parámetros de una petición:
//   • url:  en la dirección, por ejemplo ?q=encino&locale=es (peticiones GET).
//   • json: en el cuerpo de la petición, como un objeto JSON.
enum Encoding: String {
    case url
    case json
}
