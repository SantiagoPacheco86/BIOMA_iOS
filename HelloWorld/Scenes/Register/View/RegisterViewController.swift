//
//  RegisterViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit
import Combine

// MARK: - RegisterViewController
//
// Formulario de registro con validaciones en vivo publicadas por el ViewModel.
// Equivale a RegisterActivity del proyecto Android.
final class RegisterViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = RegisterViewModel()
    private var cancellables = Set<AnyCancellable>()

    override var screenBackgroundColor: UIColor { BiomaTheme.authBackground }

    // MARK: - UI Components

    private let fullNameField = BiomaField(placeholder: "Nombre completo", icon: "person")
    private let emailField = BiomaField(placeholder: "Correo electrónico", icon: "envelope")
    private let usernameField = BiomaField(placeholder: "Usuario", icon: "person", helper: "Mínimo 4 caracteres")
    private let passwordField = BiomaField(placeholder: "Contraseña", icon: "lock", helper: "Mínimo 8 caracteres", secure: true)
    private let confirmationField = BiomaField(placeholder: "Confirmar contraseña", icon: "lock", secure: true)
    private let registerButton = BiomaButton("Regístrate")
    private let loginButton = BiomaButton(prompt: "¿Ya tienes una cuenta?", action: "Inicia sesión")

    /// Relación entre cada campo del ViewModel y su componente visual, en orden de captura.
    private lazy var fields: [(RegisterViewModel.Field, BiomaField)] = [
        (.fullName, fullNameField),
        (.email, emailField),
        (.username, usernameField),
        (.password, passwordField),
        (.confirmation, confirmationField)
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
    }

    // MARK: - UI Setup

    private func setupUI() {
        addMountainBackground()
        setupScrollableContent(spacing: 14, topInset: 8)

        let brand = BiomaBrandView(size: .medium)

        let title = BiomaLabel("Crea tu cuenta", style: .title)
        title.font = BiomaTheme.font(size: 30, weight: .bold, relativeTo: .largeTitle)
        title.textColor = BiomaTheme.deepForest
        title.textAlignment = .center

        let subtitle = BiomaLabel("Únete a Bioma y comienza a explorar la biodiversidad que te rodea.", style: .body)
        subtitle.font = BiomaTheme.font(size: 15, relativeTo: .body)
        subtitle.textAlignment = .center

        contentStack.addArrangedSubview(brand)
        contentStack.addArrangedSubview(title)
        contentStack.addArrangedSubview(subtitle)
        fields.forEach { contentStack.addArrangedSubview($0.1) }
        contentStack.addArrangedSubview(registerButton)
        contentStack.addArrangedSubview(loginButton)

        contentStack.setCustomSpacing(20, after: brand)
        contentStack.setCustomSpacing(6, after: title)
        contentStack.setCustomSpacing(22, after: subtitle)
        contentStack.setCustomSpacing(26, after: confirmationField)

        // Teclado y autocompletado adecuados para cada campo.
        fullNameField.input.autocapitalizationType = .words
        fullNameField.input.textContentType = .name
        emailField.input.keyboardType = .emailAddress
        emailField.input.textContentType = .emailAddress
        usernameField.input.textContentType = .username
        passwordField.input.textContentType = .newPassword
        confirmationField.input.textContentType = .newPassword

        fields.forEach { _, field in
            field.input.returnKeyType = .next
            field.input.delegate = self
        }
        confirmationField.input.returnKeyType = .done
    }

    // MARK: - Actions

    private func setupActions() {
        fields.forEach { _, field in
            field.input.addTarget(self, action: #selector(fieldChanged(_:)), for: .editingChanged)
        }
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(backToLogin), for: .touchUpInside)
    }

    @objc private func fieldChanged(_ sender: UITextField) {
        guard let entry = fields.first(where: { $0.1.input === sender }) else { return }
        viewModel.update(entry.0, value: sender.text ?? "")
    }

    @objc private func registerTapped() {
        view.endEditing(true)

        if let error = viewModel.register() {
            showAlert(title: "No se pudo registrar", message: error)
        } else {
            // Igual que el Snackbar de Android: confirmación con acción «Iniciar sesión».
            showAlert(
                title: "Registro exitoso",
                message: "Tu cuenta está lista. Inicia sesión para comenzar a explorar.",
                buttonTitle: "Iniciar sesión"
            ) { [weak self] in
                self?.backToLogin()
            }
        }
    }

    @objc private func backToLogin() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$errors
            .receive(on: RunLoop.main)
            .sink { [weak self] errors in
                self?.fields.forEach { key, field in field.showError(errors[key]) }
            }
            .store(in: &cancellables)

        viewModel.$canRegister
            .receive(on: RunLoop.main)
            .sink { [weak self] valid in
                self?.registerButton.isEnabled = valid
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {

    /// «Siguiente» avanza al próximo campo; en el último cierra el teclado.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = fields.firstIndex(where: { $0.1.input === textField }) else { return true }
        if index + 1 < fields.count {
            fields[index + 1].1.input.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
