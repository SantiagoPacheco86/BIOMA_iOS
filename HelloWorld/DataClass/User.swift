//
//  User.swift
//  HelloWorld
//
//  Created by Alumnos on 19/10/26.
//

import Foundation

// MARK: - User
// Perfil publico un usuario registrado
// Se guarda en UserDefaults, por eso NO incluye la contraseña
// La contraseña vive cifrada en el Keychain  (ver KeychainService).

// Codable permite convertirlo en DATA (JSON) para poder guardarlo,
// ya que UserDefaults no acepta structs propios directamente.

struct User: Codable {
    let username: String
    let firstName: String
    let lastName: String
}
