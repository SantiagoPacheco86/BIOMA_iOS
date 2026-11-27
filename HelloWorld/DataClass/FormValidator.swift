//
//  FormValidator.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - FormValidator
//
// Reglas de validación de BIOMA, compartidas por Registro y Mi información.
// Cada función devuelve el mensaje de error o `nil` si el valor es válido.
// Las reglas replican las del RegisterViewModel del proyecto Android.
enum FormValidator {

    /// Nombre completo: obligatorio, solo letras y espacios, mínimo 4 caracteres.
    static func fullName(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespaces)
        if text.isEmpty { return "El nombre completo es obligatorio" }
        if !matches(text, "^[\\p{L} ]+$") { return "Solo se permiten letras" }
        if text.count < 4 { return "Nombre demasiado corto" }
        return nil
    }

    /// Nombre o apellidos editados por separado: obligatorio y solo letras y espacios.
    static func name(_ value: String, field: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespaces)
        if text.isEmpty { return "\(field) es obligatorio" }
        if !matches(text, "^[\\p{L} ]+$") { return "Solo se permiten letras" }
        return nil
    }

    /// Correo: obligatorio y con formato usuario@dominio.ext.
    static func email(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespaces)
        if text.isEmpty { return "El correo es obligatorio" }
        if !matches(text, "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$") { return "Correo inválido" }
        return nil
    }

    /// Usuario: obligatorio, solo letras y números, entre 4 y 20 caracteres.
    static func username(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespaces)
        if text.isEmpty { return "El usuario es obligatorio" }
        if !matches(text, "^[A-Za-z0-9]+$") { return "No se permiten espacios ni caracteres especiales" }
        if text.count < 4 { return "Mínimo 4 caracteres" }
        if text.count > 20 { return "Máximo 20 caracteres" }
        return nil
    }

    /// Contraseña: mínimo 8 caracteres, sin espacios, con mayúsculas, minúsculas y números.
    static func password(_ value: String) -> String? {
        if value.isEmpty { return "La contraseña es obligatoria" }
        if value.contains(" ") { return "No se permiten espacios" }
        if value.count < 8 { return "Mínimo 8 caracteres" }
        let hasUpper = value.contains { $0.isUppercase }
        let hasLower = value.contains { $0.isLowercase }
        let hasDigit = value.contains { $0.isNumber }
        if !(hasUpper && hasLower && hasDigit) { return "Debe incluir mayúsculas, minúsculas y números" }
        return nil
    }

    /// Confirmación: obligatoria e idéntica a la contraseña.
    static func confirmation(_ value: String, password: String) -> String? {
        if value.isEmpty { return "Debes confirmar la contraseña" }
        if value != password { return "Las contraseñas no coinciden" }
        return nil
    }

    // MARK: - Helpers

    private static func matches(_ text: String, _ pattern: String) -> Bool {
        text.range(of: pattern, options: .regularExpression) != nil
    }
}
