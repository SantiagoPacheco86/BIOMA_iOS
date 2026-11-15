//
//  User.swift
//  HelloWorld
//
//  Created by Alumnos on 19/10/26.
//

import Foundation

// MARK: - User
//
// Perfil público de un usuario registrado.
// Se guarda en UserDefaults, por eso NO incluye la contraseña:
// la contraseña vive cifrada en el Keychain (ver KeychainService).
//
// Codable permite convertirlo en Data (JSON) para poder guardarlo,
// ya que UserDefaults no acepta structs propios directamente.
struct User: Codable, Equatable {
    var username: String
    var firstName: String
    var lastName: String
    var email: String

    /// Nombre y apellidos juntos, por ejemplo «Santiago Pacheco».
    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    /// Nombre para saludar; «Explorador» si el usuario no tiene nombre.
    var displayName: String {
        firstName.isEmpty ? "Explorador" : firstName
    }
}

// MARK: - Decoding

extension User {

    /// Decodificación tolerante: los usuarios registrados antes de agregar el
    /// correo no tienen ese campo, así que se toma una cadena vacía en su lugar.
    /// Se declara en una extensión para conservar el inicializador por miembros.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
    }
}
