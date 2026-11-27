//
//  Header.swift
//  TestPepe
//
//  Created by José De Jesús Vega López on 01/11/24.
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - Header
//
// Encabezados de autenticación de una petición.
enum Header {
    /// Petición pública, sin credenciales.
    case noHeader
    /// Envía el token de iNaturalist en el encabezado `Authorization`.
    case Authorization
}
