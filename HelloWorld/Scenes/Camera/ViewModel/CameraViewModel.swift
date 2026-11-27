//
//  CameraViewModel.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation
import Combine

// MARK: - CameraViewModel
//
// Guarda cada foto tomada como una detección y, si hay un token de
// iNaturalist configurado, intenta identificar la especie.
// Equivale a la parte de captura de DetectionViewModel en Android.
//
// Los cambios de estado pueden publicarse desde un hilo secundario; la vista
// los recibe en el principal mediante `.receive(on: RunLoop.main)`.
final class CameraViewModel {

    // MARK: - Published State

    /// Indica si hay una identificación en curso (para mostrar un indicador).
    @Published private(set) var isIdentifying = false

    // MARK: - Properties

    private let detectionStore = DetectionStore()
    private let identificationRepository: any IdentificationRepositoryProtocol

    /// La identificación solo es posible con un token de iNaturalist configurado.
    var canIdentify: Bool {
        identificationRepository.isAvailable
    }

    // MARK: - Init

    init(identificationRepository: any IdentificationRepositoryProtocol = IdentificationRepository()) {
        self.identificationRepository = identificationRepository
    }

    // MARK: - Public API

    /// Guarda la foto como una detección pendiente de identificar.
    /// - Returns: La detección creada, o `nil` si no hay sesión o falló el guardado.
    func savePhoto(_ photoData: Data) -> Detection? {
        guard let username = UserStore.shared.currentUser?.username else { return nil }
        return detectionStore.addDetection(photoData: photoData, for: username)
    }

    /// Identifica la especie de una detección y actualiza el registro guardado.
    /// - Returns: Mensaje para el usuario con el resultado.
    func identify(_ detection: Detection, photoData: Data) async -> String {
        guard let username = UserStore.shared.currentUser?.username else {
            return "Inicia sesión para identificar especies."
        }

        // Un token vencido se detecta sin llamar a la API: la foto ya quedó
        // guardada como pendiente y se indica cómo renovarlo.
        if ApiConfiguration.iNaturalistTokenStatus == .expired {
            return "Detección pendiente: tu token de iNaturalist caducó. Pega uno nuevo en Perfil › Mi información."
        }

        isIdentifying = true
        defer { isIdentifying = false }

        do {
            guard let taxon = try await identificationRepository.identify(photoData: photoData) else {
                return "No se encontró una especie para esta foto."
            }

            var identified = detection
            identified.scientificName = taxon.name
            identified.commonName = taxon.displayCommonName
            identified.taxonId = taxon.id
            detectionStore.update(identified, for: username)

            return "Especie identificada: \(taxon.displayCommonName)"
        } catch {
            return "No se pudo identificar la especie: \(error.localizedDescription)"
        }
    }
}
