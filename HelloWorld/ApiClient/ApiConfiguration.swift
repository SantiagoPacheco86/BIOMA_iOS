//
//  ApiConfiguration.swift
//  HelloWorld
//

import Foundation

// MARK: - ApiConfiguration
//
// Origen del token (JWT) de iNaturalist que exige la identificación por foto.
// Se consulta en este orden:
//
//   0. Token escrito directamente en este archivo (`tokenForTesting`).
//      TEMPORAL: solo para probar la API en el simulador.
//   1. Token pegado en la app (Mi información → Token de iNaturalist),
//      guardado en el Keychain. Es la opción para un iPhone real.
//   2. `Secrets.plist`, opción de desarrollo que no se sube al repositorio.
//
// El token se obtiene en https://www.inaturalist.org/users/api_token y
// caduca a las 24 horas. Sin token, la Cámara guarda las fotos como
// «Especie no identificada».
enum ApiConfiguration {

    // MARK: - ⚠️ TOKEN PARA PRUEBAS

    /// ⚠️ TEMPORAL: pega tu token de iNaturalist entre las comillas,
    /// reemplazando PEGA_AQUI_TU_TOKEN. Puede ser solo el valor (eyJ…) o la
    /// respuesta completa de la página: {"api_token":"eyJ…"}.
    ///
    /// No hagas commit de este archivo con tu token: el repositorio es público.
    /// Al terminar las pruebas, vuelve a dejar "PEGA_AQUI_TU_TOKEN".
    private static let tokenForTesting = "PEGA_AQUI_TU_TOKEN"

    // MARK: - Public API

    /// Token vigente a usar en las peticiones, o `nil` si no hay ninguno.
    /// Se lee cada vez, para reflejar un token recién pegado en la app.
    static var iNaturalistToken: String? {
        testingToken ?? INaturalistTokenStore().storedToken ?? bundledToken
    }

    /// Estado del token actual: vigente, caducado o inexistente.
    static var iNaturalistTokenStatus: INaturalistTokenStatus {
        INaturalistTokenStore.status(of: iNaturalistToken)
    }

    // MARK: - Sources

    /// Token escrito en `tokenForTesting`, o `nil` si sigue el texto de ejemplo.
    private static var testingToken: String? {
        let text = tokenForTesting.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text != "PEGA_AQUI_TU_TOKEN" else { return nil }

        // Toma solo el JWT (tres partes separadas por puntos), por si se pegó
        // la respuesta completa con {"api_token": …}.
        let pattern = "[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+"
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }

    /// Token de `Secrets.plist`, leído una sola vez al primer uso.
    private static let bundledToken: String? = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let token = plist["INaturalistAPIToken"] as? String else {
            return nil
        }
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }()
}
