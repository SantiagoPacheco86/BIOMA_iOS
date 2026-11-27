//
//  DetectionHistoryViewModel.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation
import Combine

// MARK: - DetectionHistoryViewModel
//
// Estado del Historial: todas las detecciones del usuario y el contador
// «X de 50 detecciones» según el rango configurado en Mi información.
// Equivale a DetectionViewModel del proyecto Android.
final class DetectionHistoryViewModel {

    // MARK: - Published State

    @Published private(set) var detections: [DetectionItem] = []
    @Published private(set) var counterText = "0 de \(DetectionStore.totalSpecies) detecciones"

    // MARK: - Properties

    private let detectionStore = DetectionStore()

    // MARK: - Public API

    /// Vuelve a leer las detecciones; se llama cada vez que la pantalla aparece.
    func reload() {
        guard let username = UserStore.shared.currentUser?.username else {
            detections = []
            counterText = "0 de \(DetectionStore.totalSpecies) detecciones"
            return
        }

        detections = detectionStore.detections(for: username).map {
            DetectionItem(detection: $0, photoData: detectionStore.photoData(for: $0, username: username))
        }
        let count = detectionStore.recentCount(for: username)
        counterText = "\(count) de \(DetectionStore.totalSpecies) detecciones"
    }
}
