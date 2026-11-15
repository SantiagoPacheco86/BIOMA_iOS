//
//  KeychainService.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 11/11/26.
//

import Foundation

//MARK: - KeychainService

// Guarda, lee y borra contraseñas en el Keychain de iOS.
// A diferencia de UserDefaults, el Keychain esta cifrado por el sistema,
// por eso es el lugar correcto para credenciales.

struct KeychainService {
    //MARK: - Properties
    
    // Agrupa todas las contraseñas de BIOMA dentro del KeyChain
    private let service = "com.bioma.credentials"
    
    // MARK: - Public API
    
    // Guarda (o reemplaza) la contraseña de una cuenta.
    // - Retruns: "true" si se guardo correctamente.
    @discardableResult
    func savePassword(_ password: String, for account: String) -> Bool {
        // 1. Si ya existia una contraseña para esta cuenta, la borramosn
        // para evitar el error "elemento duplicado"
        deletePassword(for: account)
        
        // 2. Partimos de la consulta base y agregamos el dato a guardar.
        var query = baseQuery(for: account)
        query[kSecValueData as String] = Data(password.utf8)
        // Solo legible con el dispositivo desbloqueado y no se copia a otros equipos.
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        
        // 3. Pedimos al sistema que lo guarde.
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("⚠️ Keychain: no se pudo guardar (OSSStatus \(status))")
        }
        return status == errSecSuccess
    }
    
    /// Lee la contraseña de una cuenta.
    /// - Returns: la contraseña o "nil" si no existe.
    func readPassword(for account: String) -> String? {
        var query = baseQuery(for: account)
        query[kSecReturnData as String] = true
        // Queremos el contenido...
        query[kSecMatchLimit as String] = kSecMatchLimitOne // ... de un solo elemento
        
        // SecItemCopyMatching escribe el resultado en "result".
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Borrar la contraseña de una cuenta.
    /// - Returns: "true" si se borro o si no existia
    @discardableResult
    func deletePassword(for account: String) -> Bool {
        let status = SecItemDelete(baseQuery(for: account) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Helpers
    
    /// Consulta que identifica una contraseña: tipo + servicio + cuenta
    private func baseQuery(for account: String) -> [String: Any] {
        [
            kSecClass as String:
                kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
    
}
