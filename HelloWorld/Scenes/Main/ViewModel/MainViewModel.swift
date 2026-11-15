import Foundation
import Combine

final class MainViewModel {
    @Published private(set) var isValidForm = false
    @Published private(set) var usernameError: String?
    @Published private(set) var passwordError: String?

    private(set) var username = ""
    private(set) var password = ""

    func updateUsername(_ text: String) {
        username = text.trimmingCharacters(in: .whitespacesAndNewlines)
        validateForm()
    }

    func updatePassword(_ text: String) {
        password = text
        validateForm()
    }

    func validateForm(showErrors: Bool = false) {
        let userValid = !username.isEmpty
        let passwordValid = !password.isEmpty
        isValidForm = userValid && passwordValid
        usernameError = showErrors && !userValid ? "El usuario es obligatorio" : nil
        passwordError = showErrors && !passwordValid ? "La contraseña es obligatoria" : nil
    }

    func login() -> Bool {
        validateForm(showErrors: true)
        guard isValidForm else { return false }

        let isAuthenticated = UserStore.shared.authenticate(username: username, password: password)

        // Solo un inicio de sesión exitoso con contraseña habilita
        // el acceso biométrico y asocia la foto de perfil al usuario.
        if isAuthenticated {
            UserStore.shared.rememberLogin(username: username)
        }
        return isAuthenticated
    }
    
    // MARK: - Biometric login

    /// Resultado del inicio de sesión biométrico, listo para la vista.
    enum BiometricLoginResult {
        case success
        case cancelled               // El usuario canceló: no se muestra ningún mensaje.
        case failed(message: String)
    }

    private let biometrics = BiometricAuthService()

    /// Biometría disponible para iniciar sesión.
    /// Es `.none` si el dispositivo no la tiene o si nadie ha iniciado sesión antes con contraseña.
    var biometricLoginKind: BiometricAuthService.BiometryKind {
        guard UserStore.shared.biometricUsername != nil else { return .none }
        return biometrics.availableBiometry()
    }

    /// Inicia sesión como el último usuario usando la biometría del dispositivo.
    func loginWithBiometrics(completion: @escaping (BiometricLoginResult) -> Void) {
        guard let username = UserStore.shared.biometricUsername else {
            completion(.failed(message: "Inicia sesión con tu contraseña al menos una vez para activar este acceso."))
            return
        }

        biometrics.authenticate(reason: "Inicia sesión en BIOMA como \(username).") { result in
            switch result {
            case .success:
                // La biometría confirmó al dueño del dispositivo: se inicia su sesión.
                UserStore.shared.startBiometricSession()
                completion(.success)

            case .failure(let error):
                switch error.code {
                case .userCancel, .systemCancel, .appCancel, .userFallback:
                    completion(.cancelled)
                case .biometryLockout:
                    completion(.failed(message: "Demasiados intentos fallidos. Ingresa con tu contraseña."))
                case .biometryNotEnrolled, .biometryNotAvailable:
                    completion(.failed(message: "La biometría no está configurada en este dispositivo."))
                default:
                    completion(.failed(message: "No se pudo verificar tu identidad. Intenta de nuevo o usa tu contraseña."))
                }
            }
        }
    }
}
