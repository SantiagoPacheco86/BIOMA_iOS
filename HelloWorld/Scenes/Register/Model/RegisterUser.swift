//
//  RegisterUser.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

// MARK: - RegisterUser
//
// Datos capturados en el formulario de registro.
// El nombre completo se divide en nombre y apellidos en el primer espacio,
// igual que en el proyecto Android. La confirmación de contraseña es un
// campo del formulario y no forma parte del usuario.
struct RegisterUser {
    var fullName: String = ""
    var email: String = ""
    var username: String = ""
    var password: String = ""

    /// Primera palabra del nombre completo.
    var firstName: String {
        splitName.first
    }

    /// Resto del nombre completo, después del primer espacio.
    var lastName: String {
        splitName.last
    }

    private var splitName: (first: String, last: String) {
        let parts = fullName
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ", maxSplits: 1)
            .map { String($0).trimmingCharacters(in: .whitespaces) }
        return (parts.first ?? "", parts.count > 1 ? parts[1] : "")
    }
}
