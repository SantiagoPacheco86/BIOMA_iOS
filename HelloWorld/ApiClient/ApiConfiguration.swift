//
//  ApiConfiguration.swift
//  HelloWorld
//

import Foundation

// MARK: - ApiConfiguration
//
// Lee la configuración privada de la API desde el archivo `Secrets.plist`.
//
// Ese archivo NO se sube al repositorio (está en .gitignore) porque contiene
// el token personal de iNaturalist. Para crearlo, copia `Secrets.example.plist`
// (en la raíz del repositorio) a `HelloWorld/Secrets.plist`, junto a Info.plist, y escribe
// tu token en la clave `INaturalistAPIToken`.
//
// Sin ese archivo la app funciona igual, pero la Cámara no identifica especies.
enum ApiConfiguration {

    /// Token (JWT) de iNaturalist, o `nil` si no está configurado.
    /// Se obtiene en https://www.inaturalist.org/users/api_token y caduca a las 24 horas.
    static let iNaturalistToken: String? = {
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
