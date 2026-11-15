//
//  IdentificationRepository.swift
//  HelloWorld
//

import Foundation

// MARK: - IdentificationRepositoryProtocol
//
// Identificación de especies a partir de una foto con la visión por
// computadora de iNaturalist.
protocol IdentificationRepositoryProtocol {
    /// `true` cuando hay un token configurado y la identificación es posible.
    var isAvailable: Bool { get }
    /// Especie más probable para la foto, o `nil` si no hubo sugerencias.
    func identify(photoData: Data) async throws -> INatTaxon?
}

// MARK: - IdentificationRepository

actor IdentificationRepository: IdentificationRepositoryProtocol {

    /// Solo lee la configuración, por eso puede consultarse sin esperar al actor.
    nonisolated var isAvailable: Bool {
        ApiConfiguration.iNaturalistToken != nil
    }

    func identify(photoData: Data) async throws -> INatTaxon? {
        let request = ApiRequestModel(
            endpoint: .scoreImage,
            method: .post,
            header: .Authorization,   // Este endpoint requiere el token de iNaturalist.
            encoding: .json,
            parameters: nil
        )
        let response = try await ApiService.shared.upload(request, imageData: photoData, INatScoreResponse.self)

        // La API ordena las sugerencias de la más a la menos probable.
        return response.results?.first?.taxon
    }
}
