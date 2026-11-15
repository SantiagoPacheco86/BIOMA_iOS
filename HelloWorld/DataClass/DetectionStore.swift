//
//  DetectionStore.swift
//  HelloWorld
//

import Foundation

// MARK: - DetectionStore
//
// Guarda las detecciones de cada usuario:
//
//   • Lista de detecciones (JSON) → UserDefaults, una clave por usuario.
//   • Fotografías (JPEG)          → Application Support/Detections/<usuario>/.
//   • Rango del contador          → UserDefaults, una clave por usuario.
//
// Las fotos no se guardan en UserDefaults porque este mecanismo está pensado
// solo para datos pequeños. Equivale a la parte de detecciones de
// ConcreteSharedPreference en el proyecto Android.
struct DetectionStore {

    /// Total de especies del catálogo, usado en el contador «X de 50».
    /// Mismo valor provisional que en el proyecto Android.
    static let totalSpecies = 50

    // MARK: - Properties

    private let defaults: UserDefaults
    private let fileManager = FileManager.default

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Detections

    /// Detecciones del usuario, de la más reciente a la más antigua.
    func detections(for username: String) -> [Detection] {
        guard let data = defaults.data(forKey: detectionsKey(for: username)) else { return [] }

        do {
            return try JSONDecoder().decode([Detection].self, from: data)
        } catch {
            print("⚠️ DetectionStore: no se pudieron leer las detecciones: \(error)")
            return []
        }
    }

    /// Guarda una foto nueva como detección pendiente de identificar.
    /// - Returns: La detección creada, o `nil` si no se pudo guardar la foto.
    func addDetection(photoData: Data, for username: String) -> Detection? {
        let detection = Detection(
            id: UUID(),
            photoFileName: "\(UUID().uuidString).jpg",
            timestamp: Date(),
            scientificName: Detection.unidentifiedScientificName,
            commonName: Detection.unidentifiedCommonName,
            taxonId: nil
        )

        guard let url = photoURL(fileName: detection.photoFileName, username: username) else { return nil }

        do {
            try fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try photoData.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("⚠️ DetectionStore: no se pudo guardar la foto: \(error)")
            return nil
        }

        // La más reciente va al inicio de la lista, como en Android.
        var all = detections(for: username)
        all.insert(detection, at: 0)
        guard save(all, for: username) else {
            try? fileManager.removeItem(at: url)
            return nil
        }
        return detection
    }

    /// Reemplaza una detección existente (por ejemplo, después de identificarla).
    @discardableResult
    func update(_ detection: Detection, for username: String) -> Bool {
        var all = detections(for: username)
        guard let index = all.firstIndex(where: { $0.id == detection.id }) else { return false }
        all[index] = detection
        return save(all, for: username)
    }

    /// Bytes de la foto de una detección, o `nil` si el archivo no existe.
    func photoData(for detection: Detection, username: String) -> Data? {
        guard let url = photoURL(fileName: detection.photoFileName, username: username),
              fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            print("⚠️ DetectionStore: no se pudo leer la foto: \(error)")
            return nil
        }
    }

    // MARK: - Range

    /// Rango configurado para el contador; «Para siempre» por defecto.
    func range(for username: String) -> DetectionRange {
        let stored = defaults.string(forKey: rangeKey(for: username)) ?? ""
        return DetectionRange(rawValue: stored) ?? .forever
    }

    func setRange(_ range: DetectionRange, for username: String) {
        defaults.set(range.rawValue, forKey: rangeKey(for: username))
    }

    /// Cuántas detecciones caen dentro del rango configurado.
    func recentCount(for username: String) -> Int {
        let all = detections(for: username)
        guard let cutoff = range(for: username).cutoffDate else { return all.count }
        return all.filter { $0.timestamp >= cutoff }.count
    }

    // MARK: - Helpers

    private func save(_ detections: [Detection], for username: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(detections)
            defaults.set(data, forKey: detectionsKey(for: username))
            return true
        } catch {
            print("⚠️ DetectionStore: no se pudieron guardar las detecciones: \(error)")
            return false
        }
    }

    private func detectionsKey(for username: String) -> String {
        "bioma.detections.\(username.lowercased())"
    }

    private func rangeKey(for username: String) -> String {
        "bioma.detectionRange.\(username.lowercased())"
    }

    /// Ruta: Application Support/Detections/<usuario>/<archivo>.jpg
    private func photoURL(fileName: String, username: String) -> URL? {
        guard let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return baseURL
            .appendingPathComponent("Detections", isDirectory: true)
            .appendingPathComponent(username.lowercased(), isDirectory: true)
            .appendingPathComponent(fileName)
    }
}
