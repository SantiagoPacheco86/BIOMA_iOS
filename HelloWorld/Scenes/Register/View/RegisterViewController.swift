import UIKit
import Combine

// VIEW: formulario programático con validaciones publicadas por el ViewModel.
final class RegisterViewController: UIViewController {
    private let viewModel = RegisterViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let content = UIStackView()

    private let usernameField = BiomaField(placeholder: "Usuario")
    private let firstNameField = BiomaField(placeholder: "Nombre(s)")
    private let lastNameField = BiomaField(placeholder: "Apellido(s)")
    private let passwordField = BiomaField(placeholder: "Contraseña", secure: true)
    private let confirmationField = BiomaField(placeholder: "Confirmar contraseña", secure: true)
    private let registerButton = BiomaButton("Registrarme")

    private lazy var fields: [(String, BiomaField)] = [
        ("username", usernameField), ("firstName", firstNameField),
        ("lastName", lastNameField), ("password", passwordField),
        ("confirmation", confirmationField)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
    }

    private func setupUI() {
        view.backgroundColor = BiomaTheme.background
        title = "Registro"
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.axis = .vertical
        content.spacing = 14
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(content)

        let titleLabel = BiomaLabel("Crea tu cuenta", style: .title)
        let subtitle = BiomaLabel("Comienza a explorar la naturaleza con BIOMA.", style: .body)
        content.addArrangedSubview(titleLabel)
        content.addArrangedSubview(subtitle)
        content.setCustomSpacing(26, after: subtitle)
        fields.forEach { content.addArrangedSubview($0.1) }
        content.addArrangedSubview(registerButton)
        content.setCustomSpacing(24, after: confirmationField)

        // Mismo enlace de dos tonos que usa el Login, para mantener consistencia.
        let backButton = BiomaButton(prompt: "¿Ya tienes una cuenta?", action: "Inicia sesión")
        backButton.addTarget(self, action: #selector(backToLogin), for: .touchUpInside)
        content.addArrangedSubview(backButton)

        fields.forEach { _, field in field.input.returnKeyType = .next; field.input.delegate = self }
        confirmationField.input.returnKeyType = .done
        usernameField.input.textContentType = .username
        firstNameField.input.textContentType = .givenName
        lastNameField.input.textContentType = .familyName
        passwordField.input.textContentType = .newPassword
        confirmationField.input.textContentType = .newPassword
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    private func setupActions() {
        fields.forEach { _, field in
            field.input.addTarget(self, action: #selector(fieldChanged(_:)), for: .editingChanged)
        }
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }

    private func setupBindings() {
        viewModel.$errors.receive(on: RunLoop.main).sink { [weak self] errors in
            self?.fields.forEach { key, field in field.showError(errors[key]) }
        }.store(in: &cancellables)
        viewModel.$canRegister.receive(on: RunLoop.main).sink { [weak self] valid in
            // BiomaButton ajusta su apariencia de deshabilitado por sí mismo.
            self?.registerButton.isEnabled = valid
        }.store(in: &cancellables)
    }

    @objc private func fieldChanged(_ sender: UITextField) {
        guard let entry = fields.first(where: { $0.1.input === sender }) else { return }
        viewModel.update(field: entry.0, value: sender.text ?? "")
    }

    @objc private func registerTapped() {
        view.endEditing(true)
        if let error = viewModel.register() {
            showAlert("No se pudo registrar", error, returnToLogin: false)
        } else {
            showAlert("Registro exitoso", "Tu cuenta de demostración está lista. Inicia sesión.", returnToLogin: true)
        }
    }

    @objc private func backToLogin() {
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(_ title: String, _ message: String, returnToLogin: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { [weak self] _ in
            if returnToLogin { self?.navigationController?.popViewController(animated: true) }
        })
        present(alert, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = fields.firstIndex(where: { $0.1.input === textField }) else { return true }
        if index + 1 < fields.count { fields[index + 1].1.input.becomeFirstResponder() }
        else { textField.resignFirstResponder() }
        return true
    }
}
