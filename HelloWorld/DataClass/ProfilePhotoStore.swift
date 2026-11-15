//
//  ProfilePhotoStore.swift
//  HelloWorld
//

import Foundation

// MARK: - ProfilePhotoStore
//
// Guarda y recupera la foto de perfil de cada usuario como un archivo JPEG
// en la carpeta Application Support de la aplicación.
//
// Las imágenes no se almacenan en UserDefaults porque este mecanismo está
// diseñado únicamente para datos pequeños.
struct ProfilePhotoStore {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let folderName = "ProfilePhotos"

    // MARK: - Public API

    /// Guarda (o reemplaza) la foto de un usuario.
    /// - Returns: `true` si el archivo se escribió correctamente.
    @discardableResult
    func save(_ data: Data, for username: String) -> Bool {
        guard let url = fileURL(for: username) else { return false }

        do {
            // Crea la carpeta ProfilePhotos si todavía no existe.
            try fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            // .atomic evita archivos corruptos si la escritura se interrumpe.
            // .completeFileProtection cifra el archivo mientras el dispositivo está bloqueado.
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return true
        } catch {
            print("⚠️ ProfilePhotoStore: no se pudo guardar la foto: \(error)")
            return false
        }
    }

    /// Recupera la foto de un usuario.
    /// - Returns: los bytes de la imagen, o `nil` si el usuario no tiene foto.
    func load(for username: String) -> Data? {
        guard let url = fileURL(for: username),
              fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            print("⚠️ ProfilePhotoStore: no se pudo leer la foto: \(error)")
            return nil
        }
    }

    /// Elimina la foto de un usuario.
    /// - Returns: `true` si se eliminó o si no existía.
    @discardableResult
    func delete(for username: String) -> Bool {
        guard let url = fileURL(for: username),
              fileManager.fileExists(atPath: url.path) else {
            return true
        }

        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            print("⚠️ ProfilePhotoStore: no se pudo eliminar la foto: \(error)")
            return false
        }
    }

    // MARK: - Helpers

    /// Ruta del archivo: Application Support/ProfilePhotos/<usuario>.jpg
    private func fileURL(for username: String) -> URL? {
        guard let baseURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        return baseURL
            .appendingPathComponent(folderName, isDirectory: true)
            .appendingPathComponent("\(username.lowercased()).jpg")
    }
}
