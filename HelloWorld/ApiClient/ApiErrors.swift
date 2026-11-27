//
//  ApiErrors.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - NetworkingError
//
// Errores de red traducidos a mensajes comprensibles para el usuario.
enum NetworkingError: Error {
    case customError(msg: String)
    case generalError
    case invalidURL
    case timeOut
    case connectionLost
    case noConnection
    case httpResponseError
    case unauthorized
    case serverError
    case decodingError
}

extension NetworkingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .customError(let msg): return msg
        case .generalError:         return "Ocurrió un error al consultar el servicio."
        case .invalidURL:           return "La dirección del servicio no es válida."
        case .timeOut:              return "El servicio tardó demasiado en responder."
        case .connectionLost:       return "Se perdió la conexión de red."
        case .noConnection:         return "No hay conexión a internet."
        case .httpResponseError:    return "El servicio respondió de forma inesperada."
        case .unauthorized:         return "El token de iNaturalist no es válido o ya caducó. Pega uno nuevo en Perfil › Mi información."
        case .serverError:          return "El servicio no está disponible en este momento."
        case .decodingError:        return "No se pudo interpretar la respuesta del servicio."
        }
    }
}
