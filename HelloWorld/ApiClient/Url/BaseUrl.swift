//
//  BaseUrl.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//

import Foundation

// MARK: - BaseUrl
//
// Dirección base de la API de iNaturalist (versión 1).
// Documentación: https://api.inaturalist.org/v1/docs/
struct BaseUrl {

    static func getBaseUrl() -> String {
        "https://api.inaturalist.org/v1/"
    }

    /// Dirección completa de un endpoint, por ejemplo
    /// https://api.inaturalist.org/v1/taxa/167666
    static func getUrl(with endpoint: Endpoint) -> String {
        getBaseUrl() + endpoint.path
    }
}
