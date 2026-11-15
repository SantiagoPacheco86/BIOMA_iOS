//
//  BiomaField.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 04/11/26.
//

import UIKit

// MARK: - BiomaField
//
// Campo de texto reutilizable con su etiqueta de error debajo.
// Es un UIStackView vertical: [campo] + [error]. Cuando el error se oculta,
// el stack colapsa automáticamente su espacio.
//
// El componente NO valida: el ViewModel decide qué mensaje mostrar y el
// ViewController lo pasa a `showError(_:)`.
//
// Uso:
//     let user = BiomaField(placeholder: "Usuario")
//     let pass = BiomaField(placeholder: "Contraseña", secure: true)
//     user.showError("El usuario es obligatorio")   // nil lo oculta
final class BiomaField: UIStackView {

    // MARK: - UI Components

    /// Expuesto para que la pantalla configure delegate, returnKeyType,
    /// textContentType y targets de edición.
    let input = UITextField()
    private let errorLabel = UILabel()
    private let visibilityToggle = UIButton(type: .system)

    // MARK: - Init

    init(placeholder: String, secure: Bool = false) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = BiomaTheme.Layout.fieldErrorSpacing
        translatesAutoresizingMaskIntoConstraints = false

        setupInput(placeholder: placeholder, secure: secure)
        setupErrorLabel()
        if secure { setupVisibilityToggle() }

        addArrangedSubview(input)
        addArrangedSubview(errorLabel)
    }

    required init(coder: NSCoder) { fatalError("Use init(placeholder:secure:)") }

    // MARK: - UI Setup

    private func setupInput(placeholder: String, secure: Bool) {
        // Placeholder en color Hint, como define la paleta oficial.
        input.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: BiomaTheme.hint]
        )
        input.font = BiomaTheme.font(size: 16)
        input.adjustsFontForContentSizeCategory = true
        input.textColor = BiomaTheme.ink
        input.tintColor = BiomaTheme.forest          // Color del cursor.
        input.backgroundColor = BiomaTheme.white
        input.layer.cornerRadius = BiomaTheme.Layout.fieldCornerRadius
        input.layer.cornerCurve = .continuous
        input.layer.borderWidth = 1
        input.layer.borderColor = UIColor.clear.cgColor
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        input.isSecureTextEntry = secure
        input.accessibilityLabel = placeholder       // VoiceOver lee el nombre del campo.
        input.translatesAutoresizingMaskIntoConstraints = false

        // Vistas vacías a los lados funcionan como padding interno.
        input.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        input.leftViewMode = .always
        input.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        input.rightViewMode = .always

        // 50 pt de diseño; puede crecer con Dynamic Type.
        input.heightAnchor.constraint(
            greaterThanOrEqualToConstant: BiomaTheme.Layout.fieldHeight
        ).isActive = true
    }

    private func setupErrorLabel() {
        errorLabel.font = BiomaTheme.font(size: 12, relativeTo: .caption1)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.textColor = BiomaTheme.error
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
    }

    /// Botón de ojo para mostrar u ocultar la contraseña.
    private func setupVisibilityToggle() {
        visibilityToggle.tintColor = BiomaTheme.olive
        visibilityToggle.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        visibilityToggle.addTarget(self, action: #selector(toggleVisibility), for: .touchUpInside)
        input.rightView = visibilityToggle
        input.rightViewMode = .always
        updateVisibilityToggle()
    }

    // MARK: - Actions

    @objc private func toggleVisibility() {
        input.isSecureTextEntry.toggle()
        updateVisibilityToggle()
    }

    /// El icono y la etiqueta de accesibilidad describen la acción disponible.
    private func updateVisibilityToggle() {
        let hidden = input.isSecureTextEntry
        visibilityToggle.setImage(UIImage(systemName: hidden ? "eye" : "eye.slash"), for: .normal)
        visibilityToggle.accessibilityLabel = hidden ? "Mostrar contraseña" : "Ocultar contraseña"
    }

    // MARK: - Public API

    /// Muestra un mensaje de error bajo el campo y resalta su borde.
    /// Pasa `nil` para limpiar el error.
    ///
    /// El error no depende solo del color: siempre va acompañado de texto,
    /// que además VoiceOver lee como pista del campo.
    func showError(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil
        input.layer.borderColor = (message == nil ? UIColor.clear : BiomaTheme.error).cgColor
        input.accessibilityHint = message
    }
}
