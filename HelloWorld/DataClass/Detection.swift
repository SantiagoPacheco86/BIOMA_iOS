//
//  Detection.swift
//  HelloWorld
//

import Foundation

// MARK: - Detection
//
// Una fotografía tomada desde la pestaña Cámara y, si fue posible, la especie
// identificada. Equivale a la clase Detection del proyecto Android.
struct Detection: Codable, Identifiable, Equatable {

    /// Textos que se muestran mientras la especie no ha sido identificada.
    static let unidentifiedScientificName = "Especie no identificada"
    static let unidentifiedCommonName = "Pendiente de identificar"

    let id: UUID
    /// Nombre del archivo JPEG guardado en el dispositivo.
    let photoFileName: String
    /// Momento en que se tomó la foto.
    let timestamp: Date
    var scientificName: String
    var commonName: String
    /// Identificador del taxón en iNaturalist, cuando la especie fue identificada.
    var taxonId: Int?

    /// Indica si la detección ya tiene una especie asignada.
    var isIdentified: Bool {
        taxonId != nil
    }

    /// Fecha corta en español, por ejemplo «25 sep 2026».
    var formattedDate: String {
        Self.dateFormatter.string(from: timestamp)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}

// MARK: - DetectionRange
//
// Rango de tiempo que se toma en cuenta para el contador «X de 50 detecciones»
// del Historial. Se configura desde Mi información.
enum DetectionRange: String, CaseIterable, Codable {
    case forever = "FOREVER"
    case week = "WEEK"
    case day = "DAY"

    /// Texto visible para el usuario.
    var displayName: String {
        switch self {
        case .forever: return "Para siempre"
        case .week:    return "Una semana"
        case .day:     return "Un día"
        }
    }

    /// Fecha mínima que cuenta dentro del rango; `nil` significa sin límite.
    var cutoffDate: Date? {
        switch self {
        case .forever: return nil
        case .week:    return Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .day:     return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        }
    }
}
