import Foundation
import Combine

final class RegisterViewModel {
    // @Published permite observar el estado con Combine desde la View.
    @Published private(set) var errors: [String: String] = [:]
    @Published private(set) var canRegister = false
    @Published private(set) var isProcessing = false

    var user = RegisterUser()
    var confirmation = "" // No pertenece al modelo de usuario.
    private var touched = Set<String>()

    // Las reglas se ejecutan al editar y al enviar.
    func update(field: String, value: String) {
        switch field {
        case "username": user.username = value.trimmingCharacters(in: .whitespacesAndNewlines)
        case "firstName": user.firstName = value.trimmingCharacters(in: .whitespacesAndNewlines)
        case "lastName": user.lastName = value.trimmingCharacters(in: .whitespacesAndNewlines)
        case "password": user.password = value
        case "confirmation": confirmation = value
        default: return
        }
        touched.insert(field)
        validate()
    }

    func validate(showAll: Bool = false) {
        let all: [String: String?] = [
            "username": validateUsername(user.username),
            "firstName": validateName(user.firstName, label: "nombre"),
            "lastName": validateName(user.lastName, label: "apellido"),
            "password": validatePassword(user.password),
            "confirmation": validateConfirmation(confirmation, password: user.password)
        ]
        canRegister = all.values.allSatisfy { $0 == nil } && !isProcessing
        errors = all.compactMapValues { $0 }.filter { showAll || touched.contains($0.key) }
    }

    // Reglas de la actividad: 4...20, alfanumérico, iniciar con letra.
    private func validateUsername(_ value: String) -> String? {
        if value.isEmpty { return "El usuario es obligatorio" }
        if !(4...20).contains(value.count) { return "Debe tener entre 4 y 20 caracteres" }
        if value.range(of: "^[A-Za-z][A-Za-z0-9]*$", options: .regularExpression) == nil {
            return "Solo letras y números, sin espacios; debe iniciar con letra"
        }
        return nil
    }

    // Reglas: obligatorio, letras y espacios, 2...30.
    private func validateName(_ value: String, label: String) -> String? {
        if value.isEmpty { return "El \(label) es obligatorio" }
        if value.range(of: "^[\\p{L} ]+$", options: .regularExpression) == nil {
            return "Solo se permiten letras y espacios"
        }
        if value.count < 2 { return "El \(label) es demasiado corto (mínimo 2)" }
        if value.count > 30 { return "Máximo 30 caracteres" }
        return nil
    }

    // Reglas: mínimo 8, sin espacios, mayúscula, minúscula y número.
    private func validatePassword(_ value: String) -> String? {
        if value.isEmpty { return "La contraseña es obligatoria" }
        if value.count < 8 { return "Debe tener al menos 8 caracteres" }
        if value.rangeOfCharacter(from: .whitespacesAndNewlines) != nil {
            return "La contraseña no debe contener espacios"
        }
        let checks = ["[A-Z]", "[a-z]", "[0-9]"]
        if !checks.allSatisfy({ value.range(of: $0, options: .regularExpression) != nil }) {
            return "Debe incluir mayúsculas, minúsculas y números"
        }
        return nil
    }

    private func validateConfirmation(_ value: String, password: String) -> String? {
        if value.isEmpty { return "Debes confirmar la contraseña" }
        if value != password { return "Las contraseñas no coinciden" }
        return nil
    }

    func register() -> String? {
        validate(showAll: true)
        guard canRegister else { return "Revisa los campos del formulario" }
        isProcessing = true
        canRegister = false
        defer { isProcessing = false; validate(showAll: true) }
        guard UserStore.shared.register(user) else { return "Ese usuario ya está registrado" }
        return nil // nil = registro de demostración exitoso
    }
}
