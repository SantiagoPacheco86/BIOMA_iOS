import Foundation
import Combine

// MARK: - RegisterViewModel
//
// Estado y validación del formulario de registro.
// Las reglas viven en FormValidator y replican las del proyecto Android.
final class RegisterViewModel {

    // MARK: - Field

    /// Campos del formulario. Usar un enum evita errores de escritura en las claves.
    enum Field: CaseIterable {
        case fullName, email, username, password, confirmation
    }

    // MARK: - Published State

    /// Mensaje de error por campo; solo incluye los campos que el usuario ya editó.
    @Published private(set) var errors: [Field: String] = [:]
    /// Indica si el formulario completo es válido.
    @Published private(set) var canRegister = false

    // MARK: - Properties

    private(set) var user = RegisterUser()
    private var confirmation = ""
    /// Campos que el usuario ya modificó; los demás no muestran error todavía.
    private var touched = Set<Field>()

    // MARK: - Input

    /// Actualiza un campo y vuelve a validar el formulario.
    func update(_ field: Field, value: String) {
        switch field {
        case .fullName:     user.fullName = value
        case .email:        user.email = value.trimmingCharacters(in: .whitespaces)
        case .username:     user.username = value.trimmingCharacters(in: .whitespaces)
        case .password:     user.password = value
        case .confirmation: confirmation = value
        }
        touched.insert(field)
        validate()
    }

    // MARK: - Validation

    /// Calcula los errores de todos los campos.
    /// - Parameter showAll: `true` muestra también los errores de campos no editados.
    func validate(showAll: Bool = false) {
        let all: [Field: String?] = [
            .fullName: FormValidator.fullName(user.fullName),
            .email: FormValidator.email(user.email),
            .username: FormValidator.username(user.username),
            .password: FormValidator.password(user.password),
            .confirmation: FormValidator.confirmation(confirmation, password: user.password)
        ]
        canRegister = all.values.allSatisfy { $0 == nil }
        errors = all
            .compactMapValues { $0 }
            .filter { showAll || touched.contains($0.key) }
    }

    // MARK: - Registration

    /// Registra al usuario.
    /// - Returns: `nil` si el registro fue exitoso, o el mensaje de error.
    func register() -> String? {
        validate(showAll: true)
        guard canRegister else { return "Revisa los campos del formulario" }
        guard UserStore.shared.register(user) else { return "Ese usuario ya está registrado" }
        return nil
    }
}
