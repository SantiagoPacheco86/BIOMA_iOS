//
//  INaturalistTokenStore.swift
//  HelloWorld
//

import Foundation

// MARK: - INaturalistTokenStatus
//
// Estado del token de iNaturalist que usa la identificación por foto.
enum INaturalistTokenStatus: Equatable {
    /// No hay token guardado en la app ni en Secrets.plist.
    case missing
    /// Hay un token vigente; incluye su fecha de vencimiento si se pudo leer.
    case active(expiresAt: Date?)
    /// El token ya venció y hay que pegar uno nuevo.
    case expired

    /// Texto breve para mostrar en Mi información.
    var displayText: String {
        switch self {
        case .missing:
            return "Sin configurar"
        case .active(let expiresAt):
            guard let expiresAt else { return "Activo" }
            return "Activo · vence \(Self.formatter.string(from: expiresAt))"
        case .expired:
            return "Caducado · pega uno nuevo"
        }
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter
    }()
}

// MARK: - INaturalistTokenStore
//
// Guarda en el Keychain el token (JWT) de iNaturalist que el usuario pega en
// Mi información. Así un iPhone real puede renovar el token cada día sin
// volver a compilar la app.
//
// El token se obtiene, con la sesión de iNaturalist iniciada, en:
// https://www.inaturalist.org/users/api_token
// y caduca a las 24 horas.
struct INaturalistTokenStore {

    // MARK: - Errors

    enum TokenError: LocalizedError {
        case invalidFormat
        case alreadyExpired
        case saveFailed

        var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "El texto no parece un token de iNaturalist. Copia el valor de «api_token» completo."
            case .alreadyExpired:
                return "Ese token ya caducó. Abre la página del token para generar uno nuevo."
            case .saveFailed:
                return "No se pudo guardar el token en el dispositivo."
            }
        }
    }

    // MARK: - Properties

    /// Página donde iNaturalist muestra el token del usuario con sesión iniciada.
    static let tokenPageURL = URL(string: "https://www.inaturalist.org/users/api_token")

    private let keychain = KeychainService()
    /// Cuenta del Keychain para el token. Contiene un punto, así que no puede
    /// coincidir con un nombre de usuario de BIOMA (solo letras y números).
    private let account = "inaturalist.api_token"

    // MARK: - Public API

    /// Token guardado en la app, o `nil` si no hay ninguno.
    var storedToken: String? {
        keychain.readPassword(for: account)
    }

    /// Valida y guarda el token pegado por el usuario.
    ///
    /// Acepta el token solo o la respuesta completa de la página,
    /// por ejemplo `{"api_token":"eyJ..."}`.
    /// - Returns: La fecha de vencimiento, si el token la incluye.
    func save(_ pastedText: String) -> Result<Date?, TokenError> {
        guard let token = Self.extractToken(from: pastedText) else {
            return .failure(.invalidFormat)
        }

        let expiresAt = Self.expirationDate(of: token)
        if let expiresAt, expiresAt <= Date() {
            return .failure(.alreadyExpired)
        }

        guard keychain.savePassword(token, for: account) else {
            return .failure(.saveFailed)
        }
        return .success(expiresAt)
    }

    /// Elimina el token guardado en la app.
    func delete() {
        keychain.deletePassword(for: account)
    }

    // MARK: - JWT Helpers

    /// Estado de un token: vigente, caducado o inexistente.
    static func status(of token: String?) -> INaturalistTokenStatus {
        guard let token else { return .missing }
        guard let expiresAt = expirationDate(of: token) else { return .active(expiresAt: nil) }
        return expiresAt > Date() ? .active(expiresAt: expiresAt) : .expired
    }

    /// Lee la fecha de vencimiento (`exp`) que viene dentro del JWT.
    ///
    /// Un JWT tiene tres partes separadas por puntos: encabezado, contenido y
    /// firma. El contenido es JSON codificado en Base64URL y su campo `exp`
    /// indica el vencimiento en segundos desde 1970.
    static func expirationDate(of token: String) -> Date? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }

        // Base64URL → Base64 estándar, con el relleno «=» que falte.
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: exp)
    }

    /// Extrae el JWT de un texto pegado (token solo o JSON de la página).
    private static func extractToken(from text: String) -> String? {
        let pattern = "[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+"
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }
}
