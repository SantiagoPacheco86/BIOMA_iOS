//
//  InformationViewModel.swift
//  HelloWorld
//

import Foundation
import Combine

// MARK: - InformationViewModel
//
// Estado y acciones de «Mi información»: datos del usuario, foto de perfil,
// cambio de contraseña y rango del contador de detecciones.
// Equivale a InformationViewModel del proyecto Android.
final class InformationViewModel {

    // MARK: - Published State

    @Published private(set) var user: User?
    @Published private(set) var photoData: Data?
    @Published private(set) var range: DetectionRange = .forever
    /// Estado del token de iNaturalist usado para identificar especies.
    @Published private(set) var tokenStatus: INaturalistTokenStatus = .missing

    // MARK: - Properties

    private let photoStore = ProfilePhotoStore()
    private let detectionStore = DetectionStore()
    private let tokenStore = INaturalistTokenStore()

    /// Página donde se genera el token de iNaturalist.
    var tokenPageURL: URL? { INaturalistTokenStore.tokenPageURL }

    /// Indica si hay un token pegado en la app que se pueda eliminar.
    var hasStoredToken: Bool { tokenStore.storedToken != nil }

    /// Tipo de cuenta; por ahora todas las cuentas son estándar, igual que en Android.
    let userType = "Usuario estándar"

    // MARK: - Public API

    /// Vuelve a leer los datos del usuario con la sesión activa.
    func reload() {
        user = UserStore.shared.currentUser
        // El token es del dispositivo, no de la cuenta: se lee con o sin sesión.
        tokenStatus = ApiConfiguration.iNaturalistTokenStatus
        guard let username = user?.username else {
            photoData = nil
            range = .forever
            return
        }
        photoData = photoStore.load(for: username)
        range = detectionStore.range(for: username)
    }

    // MARK: - Editing
    //
    // Cada función devuelve `nil` si el cambio se guardó, o el mensaje de error.

    func updateFirstName(_ value: String) -> String? {
        if let error = FormValidator.name(value, field: "El nombre") { return error }
        return save { UserStore.shared.updateCurrentUser(firstName: value) }
    }

    func updateLastName(_ value: String) -> String? {
        if let error = FormValidator.name(value, field: "El apellido") { return error }
        return save { UserStore.shared.updateCurrentUser(lastName: value) }
    }

    func updateEmail(_ value: String) -> String? {
        if let error = FormValidator.email(value) { return error }
        return save { UserStore.shared.updateCurrentUser(email: value) }
    }

    func updatePassword(_ value: String) -> String? {
        if let error = FormValidator.password(value) { return error }
        return save { UserStore.shared.changePassword(to: value) }
    }

    // MARK: - iNaturalist Token

    /// Guarda el token pegado por el usuario.
    /// - Returns: `nil` si se guardó, o el mensaje de error.
    func saveToken(_ pastedText: String) -> String? {
        switch tokenStore.save(pastedText) {
        case .success:
            tokenStatus = ApiConfiguration.iNaturalistTokenStatus
            return nil
        case .failure(let error):
            return error.localizedDescription
        }
    }

    /// Elimina el token pegado en la app.
    func deleteToken() {
        tokenStore.delete()
        tokenStatus = ApiConfiguration.iNaturalistTokenStatus
    }

    /// Cambia el rango de tiempo del contador de detecciones.
    func setRange(_ newRange: DetectionRange) {
        guard let username = user?.username else { return }
        detectionStore.setRange(newRange, for: username)
        range = newRange
    }

    /// Guarda la nueva foto de perfil.
    /// - Returns: `true` si se guardó correctamente.
    func savePhoto(_ data: Data) -> Bool {
        guard let username = user?.username, photoStore.save(data, for: username) else { return false }
        photoData = data
        return true
    }

    // MARK: - Helpers

    /// Ejecuta el guardado y, si tuvo éxito, vuelve a leer los datos.
    private func save(_ operation: () -> Bool) -> String? {
        guard operation() else { return "No se pudo guardar el cambio. Intenta de nuevo." }
        reload()
        return nil
    }
}
