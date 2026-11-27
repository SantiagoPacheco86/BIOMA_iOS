//
//  MainViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit
import Combine

// MARK: - MainViewController
//
// Pantalla de inicio de sesión (Login).
// VIEW: construye los componentes, aplica constraints y reacciona al ViewModel.
// Equivale a MainActivity del proyecto Android.
final class MainViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()

    override var screenBackgroundColor: UIColor { BiomaTheme.authBackground }

    // MARK: - UI Components

    private let usernameField = BiomaField(placeholder: "Usuario", icon: "person")
    private let passwordField = BiomaField(placeholder: "Contraseña", icon: "lock", secure: true)
    private let loginButton = BiomaButton("Ingresar")
    private let registerButton = BiomaButton(prompt: "¿No tienes una cuenta?", action: "Regístrate")
    /// Acceso biométrico; solo es visible cuando está disponible.
    private let biometricButton = BiomaButton("Iniciar con Face ID", icon: "faceid", style: .outline)
    private lazy var biometricRow = centered(biometricButton)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBiometricButton()
    }

    // MARK: - UI Setup

    private func setupUI() {
        addMountainBackground()
        setupScrollableContent(spacing: 16, topInset: 24)

        let brand = BiomaBrandView(size: .large)

        let title = BiomaLabel("¡Bienvenido!", style: .title)
        title.font = BiomaTheme.font(size: 32, weight: .bold, relativeTo: .largeTitle)
        title.textColor = BiomaTheme.deepForest
        title.textAlignment = .center

        let subtitle = BiomaLabel(
            "Inicia sesión para continuar explorando la biodiversidad que te rodea.",
            style: .body
        )
        subtitle.font = BiomaTheme.font(size: 16, relativeTo: .body)
        subtitle.textAlignment = .center

        [brand, title, subtitle, usernameField, passwordField, loginButton, registerButton, biometricRow].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(28, after: brand)
        contentStack.setCustomSpacing(8, after: title)
        contentStack.setCustomSpacing(28, after: subtitle)
        contentStack.setCustomSpacing(24, after: passwordField)
        contentStack.setCustomSpacing(12, after: loginButton)
        contentStack.setCustomSpacing(12, after: registerButton)

        usernameField.input.textContentType = .username
        passwordField.input.textContentType = .password
        usernameField.input.returnKeyType = .next
        passwordField.input.returnKeyType = .done
        usernameField.input.delegate = self
        passwordField.input.delegate = self
    }

    /// Muestra el botón biométrico con el nombre e icono correctos,
    /// o lo oculta si no está disponible. El stack libera su espacio automáticamente.
    private func updateBiometricButton() {
        let kind = viewModel.biometricLoginKind
        biometricRow.isHidden = (kind == .none)
        biometricButton.setTitle("Iniciar con \(kind.displayName)", icon: kind.symbolName)
    }

    // MARK: - Actions

    private func setupActions() {
        usernameField.input.addTarget(self, action: #selector(usernameChanged), for: .editingChanged)
        passwordField.input.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        biometricButton.addTarget(self, action: #selector(biometricTapped), for: .touchUpInside)
    }

    @objc private func usernameChanged() { viewModel.updateUsername(usernameField.input.text ?? "") }
    @objc private func passwordChanged() { viewModel.updatePassword(passwordField.input.text ?? "") }

    @objc private func registerTapped() {
        push(RegisterViewController())
    }

    @objc private func loginTapped() {
        // El ViewModel valida el formulario y verifica las credenciales.
        guard viewModel.login() else {
            showAlert(title: "Error", message: "Usuario o contraseña incorrectos")
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
                self.showAlert(title: "No se pudo ingresar", message: message)
            }
        }
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$isValidForm
            .receive(on: RunLoop.main)
            .sink { [weak self] valid in
                // BiomaButton ajusta su apariencia de deshabilitado por sí mismo.
                self?.loginButton.isEnabled = valid
            }
            .store(in: &cancellables)

        viewModel.$usernameError
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.usernameField.showError($0) }
            .store(in: &cancellables)

        viewModel.$passwordError
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.passwordField.showError($0) }
            .store(in: &cancellables)
    }

    // MARK: - Navigation

    /// Sustituye el Login por Home como pantalla raíz de la ventana.
    private func navigateToHome() {
        view.endEditing(true)

        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            assertionFailure("No se encontró el SceneDelegate de la ventana actual")
            return
        }
        sceneDelegate.showHome()
    }
}

// MARK: - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {

    /// «Siguiente» pasa a la contraseña; «Listo» cierra el teclado.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField.input {
            passwordField.input.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
