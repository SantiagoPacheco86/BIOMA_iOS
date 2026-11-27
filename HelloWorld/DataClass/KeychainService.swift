//
//  KeychainService.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 11/11/26.
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation

// MARK: - KeychainService
//
// Guarda, lee y borra contraseñas en el Keychain de iOS.
// A diferencia de UserDefaults, el Keychain está cifrado por el sistema,
// por eso es el lugar adecuado para credenciales y tokens.

struct KeychainService {
    // MARK: - Properties
    
    /// Servicio que agrupa todas las credenciales de BIOMA dentro del Keychain.
    private let service = "com.bioma.credentials"
    
    // MARK: - Public API
    
    /// Guarda (o reemplaza) la contraseña de una cuenta.
    /// - Returns: `true` si se guardó correctamente.
    @discardableResult
    func savePassword(_ password: String, for account: String) -> Bool {
        // 1. Una contraseña previa de la misma cuenta se elimina primero,
        //    porque el Keychain rechaza elementos duplicados.
        deletePassword(for: account)
        
        // 2. La consulta base se completa con el dato que se va a guardar.
        var query = baseQuery(for: account)
        query[kSecValueData as String] = Data(password.utf8)
        // Solo legible con el dispositivo desbloqueado y no se copia a otros equipos.
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        
        // 3. El sistema guarda el elemento y devuelve un código de estado.
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("⚠️ Keychain: no se pudo guardar (OSStatus \(status))")
        }
        return status == errSecSuccess
    }
    
    /// Lee la contraseña de una cuenta.
    /// - Returns: La contraseña, o `nil` si no existe.
    func readPassword(for account: String) -> String? {
        var query = baseQuery(for: account)
        // La consulta solicita el contenido (los bytes) de un único elemento.
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        // SecItemCopyMatching escribe el elemento encontrado en `result`.
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Borra la contraseña de una cuenta.
    /// - Returns: `true` si se borró o si no existía.
    @discardableResult
    func deletePassword(for account: String) -> Bool {
        let status = SecItemDelete(baseQuery(for: account) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Helpers
    
    /// Consulta que identifica una contraseña: tipo + servicio + cuenta.
    private func baseQuery(for account: String) -> [String: Any] {
        [
            kSecClass as String:
                kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
    
}
