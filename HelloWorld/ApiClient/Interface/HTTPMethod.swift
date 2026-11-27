//
//  HTTPMethod.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - HTTPMethod
//
// Verbos HTTP admitidos. El valor de texto (rawValue) es el que se asigna a
// `URLRequest.httpMethod`.
enum HTTPMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
