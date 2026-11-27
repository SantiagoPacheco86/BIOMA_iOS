//
//  BiometricAuthService.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation
import LocalAuthentication

// MARK: - BiometricAuthService
//
// Encapsula la autenticación biométrica del sistema (Face ID, Touch ID u
// Optic ID) mediante el framework LocalAuthentication.
//
// La biometría no identifica al usuario de BIOMA: solo confirma que la
// persona que sostiene el dispositivo es su propietario.
struct BiometricAuthService {

    // MARK: - BiometryKind

    /// Tipo de biometría disponible en el dispositivo.
    enum BiometryKind {
        case none
        case touchID
        case faceID
        case opticID

        /// Nombre comercial que se muestra al usuario.
        var displayName: String {
            switch self {
            case .none:    return ""
            case .touchID: return "Touch ID"
            case .faceID:  return "Face ID"
            case .opticID: return "Optic ID"
            }
        }

        /// SF Symbol que representa la biometría en los botones.
        var symbolName: String {
            switch self {
            case .none:    return "lock"
            case .touchID: return "touchid"
            case .faceID:  return "faceid"
            case .opticID: return "opticid"
            }
        }
    }

    // MARK: - Public API

    /// Indica qué biometría está disponible y configurada.
    /// - Returns: `.none` si el dispositivo no la tiene o el usuario no la ha configurado.
    func availableBiometry() -> BiometryKind {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        // `biometryType` solo es válido después de llamar a canEvaluatePolicy.
        switch context.biometryType {
        case .faceID:  return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default:       return .none
        }
    }

    /// Solicita la verificación biométrica.
    /// - Parameters:
    ///   - reason: Motivo mostrado en el cuadro de Touch ID.
    ///   - completion: Resultado entregado siempre en el hilo principal.
    func authenticate(reason: String, completion: @escaping (Result<Void, LAError>) -> Void) {
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"
        // Oculta el botón "Ingresar contraseña" del sistema;
        // la alternativa es el formulario de usuario y contraseña de BIOMA.
        context.localizedFallbackTitle = ""

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            // La respuesta llega en un hilo secundario; se regresa al principal
            // porque quien la recibe actualizará la interfaz.
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    let laError = (error as? LAError) ?? LAError(.authenticationFailed)
                    completion(.failure(laError))
                }
            }
        }
    }
}
