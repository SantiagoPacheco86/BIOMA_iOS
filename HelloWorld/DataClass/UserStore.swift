//
//  UserStore.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - UserStore
//
// Capa de almacenamiento de usuarios de BIOMA. Los ViewModels interactúan
// únicamente con su API pública y desconocen dónde se guardan los datos:
//
//   • Perfil (usuario, nombre, apellido, correo) → UserDefaults (persistente, sin cifrar)
//   • Contraseña                         → Keychain (persistente, cifrado)
//   • Usuario de la última sesión        → UserDefaults (persistente, sin cifrar)
//
// La información se conserva aunque se cierre la aplicación.
// Se trata de una solución local de prototipo que no sustituye a un backend.
final class UserStore {

    // MARK: - Singleton

    static let shared = UserStore()

    // MARK: - Properties

    /// Claves utilizadas en UserDefaults, centralizadas para evitar errores de escritura.
    private enum Keys {
        static let users = "bioma.registeredUsers"
        static let lastLoggedInUser = "bioma.lastLoggedInUser"
        static let biometricUser = "bioma.biometricUser"
    }

    private let defaults: UserDefaults
    private let keychain: KeychainService

    // MARK: - Init

    /// El inicializador es privado para garantizar el uso exclusivo de `UserStore.shared`.
    private init(
        defaults: UserDefaults = .standard,
        keychain: KeychainService = KeychainService()
    ) {
        self.defaults = defaults
        self.keychain = keychain
    }

    // MARK: - Registration

    /// Registra un usuario nuevo.
    /// - Returns: `false` si el usuario ya existe o si no fue posible guardarlo.
    func register(_ newUser: RegisterUser) -> Bool {
        let key = newUser.username.lowercased()
        var users = loadUsers()

        // 1. Se impide el registro de usuarios repetidos.
        guard users[key] == nil else { return false }

        // 2. La contraseña se almacena primero en el Keychain.
        guard keychain.savePassword(newUser.password, for: key) else { return false }

        // 3. El perfil, sin contraseña, se almacena en UserDefaults.
        users[key] = User(
            username: newUser.username,
            firstName: newUser.firstName,
            lastName: newUser.lastName,
            email: newUser.email.trimmingCharacters(in: .whitespaces)
        )

        // 4. Si el perfil no puede guardarse, se revierte el paso 2
        //    para no dejar un registro incompleto.
        guard saveUsers(users) else {
            keychain.deletePassword(for: key)
            return false
        }
        return true
    }

    // MARK: - Authentication

    /// Verifica que el usuario exista y que la contraseña coincida.
    func authenticate(username: String, password: String) -> Bool {
        let key = username.lowercased()

        // El usuario debe existir en UserDefaults
        // y contar con una contraseña almacenada en el Keychain.
        guard loadUsers()[key] != nil,
              let storedPassword = keychain.readPassword(for: key) else {
            return false
        }
        return storedPassword == password
    }

    // MARK: - Session
    //
    // Se guardan dos datos distintos:
    //
    //   • Sesión activa (`lastLoggedInUser`): quién está usando la app ahora.
    //     Se borra al cerrar sesión.
    //   • Usuario para biometría (`biometricUser`): el último que inició sesión
    //     con contraseña. Se conserva al cerrar sesión para que Face ID siga
    //     disponible en el Login.

    /// Usuario con la sesión activa, o `nil` si no hay sesión o el usuario ya no existe.
    var lastLoggedInUsername: String? {
        existingUser(forKey: Keys.lastLoggedInUser)
    }

    /// Último usuario que inició sesión con contraseña; habilita el acceso biométrico.
    var biometricUsername: String? {
        existingUser(forKey: Keys.biometricUser)
    }

    /// Inicia la sesión de un usuario después de verificar su contraseña.
    /// También lo recuerda para el acceso biométrico.
    func rememberLogin(username: String) {
        let key = username.lowercased()
        defaults.set(key, forKey: Keys.lastLoggedInUser)
        defaults.set(key, forKey: Keys.biometricUser)
    }

    /// Inicia la sesión del usuario recordado después de verificar su biometría.
    /// - Returns: `false` si no hay un usuario recordado.
    @discardableResult
    func startBiometricSession() -> Bool {
        guard let username = biometricUsername else { return false }
        defaults.set(username, forKey: Keys.lastLoggedInUser)
        return true
    }

    /// Perfil del usuario con la sesión activa, o `nil` si no hay sesión.
    var currentUser: User? {
        guard let username = lastLoggedInUsername else { return nil }
        return loadUsers()[username]
    }

    /// Cierra la sesión actual. La cuenta, sus detecciones, su foto y el
    /// acceso biométrico se conservan.
    func logout() {
        defaults.removeObject(forKey: Keys.lastLoggedInUser)
    }

    /// Lee un nombre de usuario guardado y comprueba que la cuenta siga existiendo.
    private func existingUser(forKey key: String) -> String? {
        guard let username = defaults.string(forKey: key),
              loadUsers()[username] != nil else {
            return nil
        }
        return username
    }

    // MARK: - Profile Editing

    /// Actualiza nombre, apellidos y correo del usuario con la sesión activa.
    /// - Returns: `false` si no hay sesión o no fue posible guardar.
    @discardableResult
    func updateCurrentUser(firstName: String? = nil, lastName: String? = nil, email: String? = nil) -> Bool {
        guard let key = lastLoggedInUsername else { return false }
        var users = loadUsers()
        guard var user = users[key] else { return false }

        if let firstName { user.firstName = firstName.trimmingCharacters(in: .whitespaces) }
        if let lastName { user.lastName = lastName.trimmingCharacters(in: .whitespaces) }
        if let email { user.email = email.trimmingCharacters(in: .whitespaces) }

        users[key] = user
        return saveUsers(users)
    }

    /// Reemplaza la contraseña del usuario con la sesión activa en el Keychain.
    /// - Returns: `false` si no hay sesión o no fue posible guardar.
    @discardableResult
    func changePassword(to newPassword: String) -> Bool {
        guard let key = lastLoggedInUsername else { return false }
        return keychain.savePassword(newPassword, for: key)
    }

    // MARK: - UserDefaults Helpers

    /// Lee el diccionario de usuarios registrados.
    /// - Returns: Un diccionario vacío si no existen datos almacenados o no pueden leerse.
    private func loadUsers() -> [String: User] {
        // `data(forKey:)` devuelve `nil` cuando la clave no existe.
        guard let data = defaults.data(forKey: Keys.users) else { return [:] }

        do {
            // Conversión de Data (JSON) a [String: User].
            return try JSONDecoder().decode([String: User].self, from: data)
        } catch {
            print("⚠️ UserStore: no se pudieron leer los usuarios: \(error)")
            return [:]
        }
    }

    /// Guarda el diccionario completo de usuarios registrados.
    /// - Returns: `true` si la información se almacenó correctamente.
    private func saveUsers(_ users: [String: User]) -> Bool {
        do {
            // Conversión de [String: User] a Data (JSON), un tipo admitido por UserDefaults.
            let data = try JSONEncoder().encode(users)
            defaults.set(data, forKey: Keys.users)
            return true
        } catch {
            print("⚠️ UserStore: no se pudieron guardar los usuarios: \(error)")
            return false
        }
    }
}
