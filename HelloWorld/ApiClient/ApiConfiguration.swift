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
//   1. Token pegado en la app (Mi información → Token de iNaturalist),
//      guardado en el Keychain. Es la opción para un iPhone real: se renueva
//      cada día sin volver a compilar.
//   2. `Secrets.plist`, opción de desarrollo. Ese archivo NO se sube al
//      repositorio (está en .gitignore). Para crearlo, copia
//      `Secrets.example.plist` (en la raíz del repositorio) a
//      `HelloWorld/Secrets.plist`, junto a Info.plist, y escribe tu token en
//      la clave `INaturalistAPIToken`.
//
// El token se obtiene en https://www.inaturalist.org/users/api_token y
// caduca a las 24 horas. Sin token, la Cámara guarda las fotos como
// «Especie no identificada».
enum ApiConfiguration {

    /// Token vigente a usar en las peticiones, o `nil` si no hay ninguno.
    /// Se lee cada vez, para reflejar un token recién pegado en la app.
    static var iNaturalistToken: String? {
        INaturalistTokenStore().storedToken ?? bundledToken
    }

    /// Estado del token actual: vigente, caducado o inexistente.
    static var iNaturalistTokenStatus: INaturalistTokenStatus {
        INaturalistTokenStore.status(of: iNaturalistToken)
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
