//
//  ApiConfiguration.swift
//  HelloWorld
//

import Foundation

// MARK: - ApiConfiguration
//
// Origen del token (JWT) de iNaturalist que exige la identificación por foto.
//
// El token lo proporciona el propio usuario: lo obtiene con su cuenta en
// https://www.inaturalist.org/users/api_token y lo pega en
// Perfil › Mi información › Token de iNaturalist. La app lo guarda cifrado en
// el Keychain mediante INaturalistTokenStore.
//
// El token caduca a las 24 horas. Sin un token vigente, la Cámara guarda las
// fotos como «Especie no identificada» y la búsqueda de Explorar, que es
// pública, sigue funcionando.
enum ApiConfiguration {

    /// Token guardado por el usuario, o `nil` si no ha pegado ninguno.
    /// Se lee en cada consulta, para reflejar un token recién guardado.
    static var iNaturalistToken: String? {
        INaturalistTokenStore().storedToken
    }

    /// Estado del token actual: vigente, caducado o inexistente.
    static var iNaturalistTokenStatus: INaturalistTokenStatus {
        INaturalistTokenStore.status(of: iNaturalistToken)
    }
}
