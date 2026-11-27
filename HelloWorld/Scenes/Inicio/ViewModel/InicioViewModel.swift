//
//  InicioViewModel.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation
import Combine

// MARK: - InicioViewModel
//
// Estado de la pantalla Inicio: saludo al usuario y sus detecciones recientes.
// Equivale a InicioViewModel del proyecto Android.
final class InicioViewModel {

    // MARK: - Constants

    /// Número de detecciones que se muestran en Inicio.
    static let recentLimit = 3

    // MARK: - Published State

    @Published private(set) var greeting = "¡Hola, Explorador!"
    @Published private(set) var recentDetections: [DetectionItem] = []

    // MARK: - Properties

    private let detectionStore = DetectionStore()

    // MARK: - Public API

    /// Vuelve a leer el usuario y sus detecciones. Se llama cada vez que la
    /// pantalla aparece, para reflejar cambios hechos en otras pestañas.
    func reload() {
        guard let user = UserStore.shared.currentUser else {
            greeting = "¡Hola, Explorador!"
            recentDetections = []
            return
        }

        greeting = "¡Hola, \(user.displayName)!"
        recentDetections = detectionStore
            .detections(for: user.username)
            .prefix(Self.recentLimit)
            .map { DetectionItem(detection: $0, photoData: detectionStore.photoData(for: $0, username: user.username)) }
    }
}

// MARK: - DetectionItem
//
// Detección lista para mostrarse: los datos y los bytes de su foto.
// La conversión de Data a UIImage la hace la vista.
struct DetectionItem {
    let detection: Detection
    let photoData: Data?
}
