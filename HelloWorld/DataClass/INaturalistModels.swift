//
//  INaturalistModels.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - INaturalist Models
//
// Data classes que convierten el JSON de iNaturalist en objetos Swift.
// Todas las propiedades opcionales evitan que la decodificación falle si
// la API omite un campo. Las CodingKeys traducen el formato snake_case de
// la API (preferred_common_name) al camelCase de Swift (preferredCommonName).

/// Respuesta de /taxa/autocomplete y /taxa/{id}.
struct INatTaxaResponse: Decodable {
    let totalResults: Int?
    let results: [INatTaxon]?

    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case results
    }
}

/// Respuesta de /computervision/score_image.
struct INatScoreResponse: Decodable {
    let results: [INatScoreResult]?
}

/// Una sugerencia de la identificación por foto, con su puntuación.
struct INatScoreResult: Decodable {
    let combinedScore: Double?
    let taxon: INatTaxon?

    enum CodingKeys: String, CodingKey {
        case combinedScore = "combined_score"
        case taxon
    }
}

// MARK: - INatTaxon

/// Una especie (o cualquier nivel taxonómico) de iNaturalist.
struct INatTaxon: Decodable, Equatable {
    let id: Int
    let name: String
    let rank: String?
    let preferredCommonName: String?
    let iconicTaxonName: String?
    let defaultPhoto: INatPhoto?
    /// Solo viene en el detalle (/taxa/{id}): reino, familia, género, etc.
    let ancestors: [INatAncestor]?
    /// Solo viene en el detalle; puede contener etiquetas HTML.
    let wikipediaSummary: String?

    enum CodingKeys: String, CodingKey {
        case id, name, rank, ancestors
        case preferredCommonName = "preferred_common_name"
        case iconicTaxonName = "iconic_taxon_name"
        case defaultPhoto = "default_photo"
        case wikipediaSummary = "wikipedia_summary"
    }
}

/// Foto representativa de una especie.
struct INatPhoto: Decodable, Equatable {
    let squareUrl: String?
    let mediumUrl: String?

    enum CodingKeys: String, CodingKey {
        case squareUrl = "square_url"
        case mediumUrl = "medium_url"
    }
}

/// Nivel taxonómico superior (por ejemplo, la familia Fagaceae).
struct INatAncestor: Decodable, Equatable {
    let rank: String?
    let name: String?
}

// MARK: - Presentation Helpers

extension INatTaxon {

    /// Nombre común en español; si no existe, el nombre científico.
    var displayCommonName: String {
        guard let common = preferredCommonName, !common.isEmpty else { return name }
        return common.prefix(1).uppercased() + common.dropFirst()
    }

    /// Familia de la especie, por ejemplo «Fagaceae».
    var family: String? {
        ancestors?.first { $0.rank == "family" }?.name
    }

    /// Género de la especie, por ejemplo «Quercus».
    var genus: String? {
        if rank == "genus" { return name }
        return ancestors?.first { $0.rank == "genus" }?.name
    }

    /// Descripción sin etiquetas HTML ni entidades.
    var plainSummary: String? {
        guard let summary = wikipediaSummary, !summary.isEmpty else { return nil }
        let withoutTags = summary.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        let decoded = withoutTags
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: " ,", with: ",")
        return decoded.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Tipo de organismo para la etiqueta «Planta», «Ave», etc., y su icono.
    var kind: (label: String, icon: String) {
        switch iconicTaxonName {
        case "Plantae":         return ("Planta", "leaf")
        case "Fungi":           return ("Hongo", "camera.macro")
        case "Aves":            return ("Ave", "bird")
        case "Mammalia":        return ("Mamífero", "pawprint")
        case "Reptilia":        return ("Reptil", "lizard")
        case "Amphibia":        return ("Anfibio", "pawprint")
        case "Actinopterygii":  return ("Pez", "fish")
        case "Insecta":         return ("Insecto", "ladybug")
        case "Arachnida":       return ("Arácnido", "ant")
        case "Mollusca":        return ("Molusco", "tortoise")
        case "Animalia":        return ("Animal", "pawprint")
        default:                return ("Organismo", "circle.hexagongrid")
        }
    }
}
