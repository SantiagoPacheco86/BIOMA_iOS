//
//  InformationViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit
import Combine

// MARK: - InformationViewController
//
// «Mi información»: datos personales editables, seguridad y opciones de la
// cuenta. Se abre desde la pestaña Perfil.
// Equivale a InformationFragment del proyecto Android.
final class InformationViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = InformationViewModel()
    private var cancellables = Set<AnyCancellable>()
    private lazy var imagePicker = ImagePickerHelper(presenter: self)

    // MARK: - UI Components

    private let avatarView = BiomaAvatarView(diameter: 112)
    private let fullNameLabel = BiomaLabel(style: .title)
    private let emailLabel = BiomaLabel(style: .body)
    private lazy var userTypeBadge = BiomaPill(viewModel.userType, icon: "person", fontSize: 14)

    private let firstNameRow = BiomaListRow(icon: "person", title: "Nombre")
    private let lastNameRow = BiomaListRow(icon: "person", title: "Apellidos")
    private let emailRow = BiomaListRow(icon: "envelope", title: "Correo electrónico")
    private let passwordRow = BiomaListRow(icon: "lock", title: "Cambiar contraseña", subtitle: "Actualiza tu contraseña de acceso")
    private lazy var userTypeRow = BiomaListRow(icon: "person.text.rectangle", title: "Tipo de usuario", subtitle: viewModel.userType)
    private let rangeRow = BiomaListRow(icon: "clock", title: "Rango de tiempo para guardar detecciones recientes")
    private let tokenRow = BiomaListRow(icon: "key", title: "Token de iNaturalist", subtitle: "Sin configurar")
    private let logoutRow = BiomaListRow(
        icon: "rectangle.portrait.and.arrow.right",
        title: "Cerrar sesión",
        subtitle: "Sal de tu cuenta en este dispositivo"
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    // MARK: - UI Setup

    private func setupUI() {
        setupScrollableContent(spacing: 14, topInset: 4)

        let header = BiomaHeaderView()
        let profileSummary = makeProfileSummary()

        let personalTitle = BiomaLabel("Información personal", style: .sectionTitle)
        let personalGroup = BiomaRowGroup(rows: [firstNameRow, lastNameRow, emailRow])

        let securityTitle = BiomaLabel("Seguridad", style: .sectionTitle)
        let securityGroup = BiomaRowGroup(rows: [passwordRow])

        let iNaturalistTitle = BiomaLabel("Identificación de especies", style: .sectionTitle)
        let iNaturalistGroup = BiomaRowGroup(rows: [tokenRow])

        let accountTitle = BiomaLabel("Cuenta", style: .sectionTitle)
        let accountGroup = BiomaRowGroup(rows: [userTypeRow, rangeRow, logoutRow])

        let versionRow = centered(BiomaPill("Bioma v1.0.0", fontSize: 13))

        [header, profileSummary, personalTitle, personalGroup, securityTitle, securityGroup,
         iNaturalistTitle, iNaturalistGroup, accountTitle, accountGroup, versionRow].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(24, after: header)
        contentStack.setCustomSpacing(28, after: profileSummary)
        contentStack.setCustomSpacing(26, after: personalGroup)
        contentStack.setCustomSpacing(26, after: securityGroup)
        contentStack.setCustomSpacing(26, after: iNaturalistGroup)
        contentStack.setCustomSpacing(30, after: accountGroup)
    }

    /// Foto, nombre completo, correo y tipo de usuario en una sola fila.
    private func makeProfileSummary() -> UIView {
        fullNameLabel.font = BiomaTheme.font(size: 26, weight: .bold, relativeTo: .title1)
        emailLabel.font = BiomaTheme.font(size: 16, relativeTo: .body)

        let badgeRow = UIStackView(arrangedSubviews: [userTypeBadge, UIView()])
        badgeRow.axis = .horizontal
        userTypeBadge.setContentHuggingPriority(.required, for: .horizontal)

        let texts = UIStackView(arrangedSubviews: [fullNameLabel, emailLabel, badgeRow])
        texts.axis = .vertical
        texts.spacing = 6
        texts.setCustomSpacing(12, after: emailLabel)

        let row = UIStackView(arrangedSubviews: [avatarView, texts])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 24
        return row
    }

    // MARK: - Actions

    private func setupActions() {
        avatarView.badgeButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        firstNameRow.addTarget(self, action: #selector(editFirstNameTapped), for: .touchUpInside)
        lastNameRow.addTarget(self, action: #selector(editLastNameTapped), for: .touchUpInside)
        emailRow.addTarget(self, action: #selector(editEmailTapped), for: .touchUpInside)
        passwordRow.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        userTypeRow.addTarget(self, action: #selector(userTypeTapped), for: .touchUpInside)
        rangeRow.addTarget(self, action: #selector(rangeTapped), for: .touchUpInside)
        tokenRow.addTarget(self, action: #selector(tokenTapped), for: .touchUpInside)
        logoutRow.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    @objc private func changePhotoTapped() {
        imagePicker.pick(from: .photoLibrary) { [weak self] image in
            guard let self else { return }
            guard let data = image.jpegData(compressionQuality: 0.8), self.viewModel.savePhoto(data) else {
                self.showAlert(title: "No se pudo guardar", message: "La foto no se pudo guardar en el dispositivo.")
                return
            }
        }
    }

    @objc private func editFirstNameTapped() {
        showEditDialog(title: "Nombre", currentValue: viewModel.user?.firstName ?? "") { [weak self] in
            self?.viewModel.updateFirstName($0)
        }
    }

    @objc private func editLastNameTapped() {
        showEditDialog(title: "Apellidos", currentValue: viewModel.user?.lastName ?? "") { [weak self] in
            self?.viewModel.updateLastName($0)
        }
    }

    @objc private func editEmailTapped() {
        showEditDialog(title: "Correo electrónico", currentValue: viewModel.user?.email ?? "", keyboard: .emailAddress) { [weak self] in
            self?.viewModel.updateEmail($0)
        }
    }

    @objc private func changePasswordTapped() {
        showEditDialog(title: "Nueva contraseña", currentValue: "", isSecure: true) { [weak self] newValue in
            let error = self?.viewModel.updatePassword(newValue)
            if error == nil { self?.showToast("Contraseña actualizada") }
            return error
        }
    }

    @objc private func userTypeTapped() {
        showToast("Cuenta de tipo: \(viewModel.userType)")
    }

    /// Lista de rangos con una marca en el rango actual.
    @objc private func rangeTapped() {
        let sheet = UIAlertController(
            title: "Rango de tiempo para guardar detecciones recientes",
            message: nil,
            preferredStyle: .actionSheet
        )

        for range in DetectionRange.allCases {
            // El rango vigente se distingue con una marca al inicio del texto.
            let title = range == viewModel.range ? "✓ \(range.displayName)" : range.displayName
            sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.viewModel.setRange(range)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        // En iPad, un actionSheet requiere un punto de anclaje.
        sheet.popoverPresentationController?.sourceView = rangeRow
        sheet.popoverPresentationController?.sourceRect = rangeRow.bounds
        present(sheet, animated: true)
    }

    // MARK: - iNaturalist Token

    /// Opciones del token: pegar uno nuevo, abrir la página donde se genera o eliminarlo.
    @objc private func tokenTapped() {
        let sheet = UIAlertController(
            title: "Token de iNaturalist",
            message: "Permite identificar especies con la Cámara. Caduca a las 24 horas.",
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Pegar token", style: .default) { [weak self] _ in
            self?.showPasteTokenDialog()
        })

        if let url = viewModel.tokenPageURL {
            sheet.addAction(UIAlertAction(title: "Obtener token en iNaturalist", style: .default) { _ in
                // Se abre en Safari; ahí se inicia sesión y se copia el valor de «api_token».
                UIApplication.shared.open(url)
            })
        }

        if viewModel.hasStoredToken {
            sheet.addAction(UIAlertAction(title: "Eliminar token", style: .destructive) { [weak self] _ in
                self?.viewModel.deleteToken()
                self?.showToast("Token eliminado")
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        // En iPad, un actionSheet requiere un punto de anclaje.
        sheet.popoverPresentationController?.sourceView = tokenRow
        sheet.popoverPresentationController?.sourceRect = tokenRow.bounds
        present(sheet, animated: true)
    }

    /// Campo para pegar el token copiado de la página de iNaturalist.
    private func showPasteTokenDialog() {
        showEditDialog(
            title: "Pegar token",
            message: "Inicia sesión en iNaturalist, abre la página del token y copia el valor de «api_token». También puedes pegar la respuesta completa.",
            currentValue: "",
            capitalization: UITextAutocapitalizationType.none
        ) { [weak self] pastedText in
            let error = self?.viewModel.saveToken(pastedText)
            if error == nil { self?.showToast("Token guardado") }
            return error
        }
    }

    @objc private func logoutTapped() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            assertionFailure("No se encontró el SceneDelegate de la ventana actual")
            return
        }
        sceneDelegate.logout()
    }

    // MARK: - Edit Dialog

    /// Muestra una alerta con un campo de texto, equivalente al AlertDialog de Android.
    /// - Parameters:
    ///   - title: Título de la alerta.
    ///   - message: Instrucciones opcionales bajo el título.
    ///   - currentValue: Valor con el que inicia el campo.
    ///   - isSecure: `true` oculta el texto (contraseñas).
    ///   - keyboard: Tipo de teclado del campo.
    ///   - capitalization: Uso de mayúsculas; si es `nil` se decide según el tipo de campo.
    ///   - onSave: Guarda el valor y devuelve un mensaje de error, o `nil` si tuvo éxito.
    private func showEditDialog(
        title: String,
        message: String? = nil,
        currentValue: String,
        isSecure: Bool = false,
        keyboard: UIKeyboardType = .default,
        capitalization: UITextAutocapitalizationType? = nil,
        onSave: @escaping (String) -> String?
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.text = currentValue
            field.isSecureTextEntry = isSecure
            field.keyboardType = keyboard
            let automatic: UITextAutocapitalizationType = isSecure || keyboard == .emailAddress ? .none : .words
            field.autocapitalizationType = capitalization ?? automatic
            field.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self, weak alert] _ in
            let value = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
            // Igual que en Android, un campo vacío no modifica nada.
            guard !value.isEmpty else { return }
            if let error = onSave(value) {
                self?.showAlert(title: "No se pudo guardar", message: error)
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$user
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                guard let self else { return }
                self.fullNameLabel.text = user?.fullName
                self.emailLabel.text = user?.email
                self.firstNameRow.subtitle = user?.firstName
                self.lastNameRow.subtitle = user?.lastName
                self.emailRow.subtitle = user?.email
            }
            .store(in: &cancellables)

        viewModel.$photoData
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.avatarView.setImage(data.flatMap(UIImage.init(data:)))
            }
            .store(in: &cancellables)

        viewModel.$range
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.rangeRow.subtitle = $0.displayName }
            .store(in: &cancellables)

        viewModel.$tokenStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.tokenRow.subtitle = $0.displayText }
            .store(in: &cancellables)
    }
}
