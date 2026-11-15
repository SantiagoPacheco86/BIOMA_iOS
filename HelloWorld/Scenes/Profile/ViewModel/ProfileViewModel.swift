//
//  ProfileViewModel.swift
//  HelloWorld
//

import Foundation
import Combine

// MARK: - ProfileViewModel
//
// Estado de la pestaña Perfil: nombre del usuario y foto de perfil.
// La foto se conserva entre sesiones gracias a ProfilePhotoStore.
// Equivale a ProfileViewModel del proyecto Android.
final class ProfileViewModel {

    // MARK: - Published State

    @Published private(set) var name = "Explorador"
    /// Bytes de la foto de perfil; `nil` si el usuario no tiene una.
    @Published private(set) var photoData: Data?

    // MARK: - Properties

    private let photoStore = ProfilePhotoStore()

    // MARK: - Public API

    /// Vuelve a leer el usuario y su foto; se llama cada vez que la pantalla aparece.
    func reload() {
        guard let user = UserStore.shared.currentUser else {
            name = "Explorador"
            photoData = nil
            return
        }
        name = user.displayName
        photoData = photoStore.load(for: user.username)
    }

    /// Guarda la nueva foto de perfil del usuario actual.
    /// - Returns: `true` si se guardó correctamente.
    func savePhoto(_ data: Data) -> Bool {
        guard let username = UserStore.shared.currentUser?.username,
              photoStore.save(data, for: username) else {
            return false
        }
        photoData = data
        return true
    }
}
