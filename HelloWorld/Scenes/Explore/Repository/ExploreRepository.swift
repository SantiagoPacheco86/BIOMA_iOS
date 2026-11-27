//
//  ExploreRepository.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - ExploreRepositoryProtocol
//
// Operaciones de búsqueda de especies. El ViewModel depende del protocolo,
// no de la implementación, igual que ListRepository en el ejemplo de clase.
protocol ExploreRepositoryProtocol {
    /// Especies cuyo nombre científico o común coincide con el texto.
    func searchTaxa(_ query: String) async throws -> [INatTaxon]
    /// Detalle completo de una especie (familia, género y descripción).
    func taxonDetail(id: Int) async throws -> INatTaxon?
}

// MARK: - ExploreRepository

actor ExploreRepository: ExploreRepositoryProtocol {

    /// Número máximo de coincidencias por búsqueda.
    private let resultsLimit = 10

    func searchTaxa(_ query: String) async throws -> [INatTaxon] {
        let request = ApiRequestModel(
            endpoint: .searchTaxa,
            method: .get,
            header: .noHeader,
            encoding: .url,
            parameters: [
                "q": query,
                "locale": "es",          // Nombres comunes en español.
                "is_active": true,
                "per_page": resultsLimit
            ]
        )
        let response = try await ApiService.shared.request(request, INatTaxaResponse.self)
        return response.results ?? []
    }

    func taxonDetail(id: Int) async throws -> INatTaxon? {
        let request = ApiRequestModel(
            endpoint: .taxonDetail(id: id),
            method: .get,
            header: .noHeader,
            encoding: .url,
            parameters: ["locale": "es"]   // Descripción de Wikipedia en español.
        )
        let response = try await ApiService.shared.request(request, INatTaxaResponse.self)
        return response.results?.first
    }
}
