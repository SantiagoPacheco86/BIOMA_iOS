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

    /// Usuario de la última sesión iniciada con contraseña.
    /// Es `nil` si nunca se ha iniciado sesión o si el usuario ya no existe.
    var lastLoggedInUsername: String? {
        guard let username = defaults.string(forKey: Keys.lastLoggedInUser),
              loadUsers()[username] != nil else {
            return nil
        }
        return username
    }

    /// Registra el usuario que acaba de iniciar sesión correctamente.
    func rememberLogin(username: String) {
        defaults.set(username.lowercased(), forKey: Keys.lastLoggedInUser)
    }

    /// Perfil del usuario con la sesión activa, o `nil` si no hay sesión.
    var currentUser: User? {
        guard let username = lastLoggedInUsername else { return nil }
        return loadUsers()[username]
    }

    /// Cierra la sesión actual. La cuenta, sus detecciones y su foto se conservan;
    /// para volver a entrar se necesitan usuario y contraseña.
    func logout() {
        defaults.removeObject(forKey: Keys.lastLoggedInUser)
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
