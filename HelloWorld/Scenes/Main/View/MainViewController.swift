import UIKit
import Combine

// VIEW: construye componentes, aplica constraints y reacciona al ViewModel.
final class MainViewController: UIViewController {
    private let viewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView()
    private let content = UIStackView()
    private let usernameField = BiomaField(placeholder: "Usuario")
    private let passwordField = BiomaField(placeholder: "Contraseña", secure: true)
    private let loginButton = BiomaButton("Ingresar")
    // Enlace de dos tonos definido en el DesignSystem.
    private let registerButton = BiomaButton(prompt: "¿No tienes una cuenta?", action: "Regístrate")
    /// Acceso biométrico; solo es visible cuando está disponible.
    private let biometricButton = BiomaButton("Ingresar con Face ID", style: .link)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBiometricButton()
    }

    /// Muestra el botón biométrico con el nombre correcto, u oculta el botón si no está disponible.
    /// Un UIStackView libera el espacio de las vistas ocultas automáticamente.
    private func updateBiometricButton() {
        let kind = viewModel.biometricLoginKind
        biometricButton.isHidden = (kind == .none)
        biometricButton.setTitle("Ingresar con \(kind.displayName)", for: .normal)
    }

    private func setupUI() {
        view.backgroundColor = BiomaTheme.background
        navigationItem.title = ""
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.axis = .vertical
        content.spacing = 16
        content.alignment = .fill
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(content)

        // Cada estilo de BiomaLabel ya trae fuente, color y alineación.
        let logo = BiomaLabel("BIOMA", style: .brand)
        let subtitle = BiomaLabel("EXPLORA · IDENTIFICA · CONOCE", style: .tagline)
        let title = BiomaLabel("¡Bienvenido!", style: .title)
        let description = BiomaLabel("Inicia sesión para continuar explorando la biodiversidad que te rodea.", style: .body)

        [logo, subtitle, title, description, usernameField, passwordField, loginButton,biometricButton, registerButton].forEach {
            content.addArrangedSubview($0)
        }
        content.setCustomSpacing(34, after: subtitle)
        content.setCustomSpacing(26, after: description)
        content.setCustomSpacing(26, after: passwordField)
        content.setCustomSpacing(18, after: loginButton)

        usernameField.input.textContentType = .username
        passwordField.input.textContentType = .password
        usernameField.input.returnKeyType = .next
        passwordField.input.returnKeyType = .done
        usernameField.input.delegate = self
        passwordField.input.delegate = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 36),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    private func setupActions() {
        usernameField.input.addTarget(self, action: #selector(usernameChanged), for: .editingChanged)
        passwordField.input.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        biometricButton.addTarget(self, action: #selector(biometricTapped), for: .touchUpInside)
    }

    private func setupBindings() {
        viewModel.$isValidForm.receive(on: RunLoop.main).sink { [weak self] valid in
            // BiomaButton ajusta su apariencia de deshabilitado por sí mismo.
            self?.loginButton.isEnabled = valid
        }.store(in: &cancellables)
        viewModel.$usernameError.receive(on: RunLoop.main).sink { [weak self] in
            self?.usernameField.showError($0)
        }.store(in: &cancellables)
        viewModel.$passwordError.receive(on: RunLoop.main).sink { [weak self] in
            self?.passwordField.showError($0)
        }.store(in: &cancellables)
    }

    @objc private func usernameChanged() { viewModel.updateUsername(usernameField.input.text ?? "") }
    @objc private func passwordChanged() { viewModel.updatePassword(passwordField.input.text ?? "") }

    @objc private func registerTapped() {
        // Navegación programática, equivalente funcional a un segue.
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }

    @objc private func loginTapped() {

        // MARK: - 1. VALIDAR CREDENCIALES

        // El ViewModel verifica que el usuario y
        // la contraseña sean correctos.
        guard viewModel.login() else {

            // Si las credenciales son incorrectas,
            // mostramos un error y detenemos la función.
            showAlert(
                "Error",
                "Usuario o contraseña incorrectos"
            )

            return
        }
        
        navigateToHome()
    
    }
    
    /// Inicio de sesión con Face ID / Touch ID / Optic ID.
    @objc private func biometricTapped() {
        view.endEditing(true)

        viewModel.loginWithBiometrics { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.navigateToHome()
            case .cancelled:
                break
            case .failed(let message):
                self.showAlert("No se pudo ingresar", message)
            }
        }
    }

    /// Sustituye el Login por Home como pantalla raíz de la ventana.
    private func navigateToHome() {
        view.endEditing(true)

        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            assertionFailure("No se encontró el SceneDelegate de la ventana actual")
            return
        }
        sceneDelegate.showHome()
    }


    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField.input { passwordField.input.becomeFirstResponder() }
        else { textField.resignFirstResponder() }
        return true
    }
}
