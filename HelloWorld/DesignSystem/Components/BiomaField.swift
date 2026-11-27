//
//  BiomaField.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 04/11/26.
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - BiomaField
//
// Campo de texto reutilizable de BIOMA. Es un UIStackView vertical:
//
//   ┌──────────────────────────────────────┐
//   │ [icono]  Placeholder / texto    [👁] │  ← tarjeta con sombra
//   │          Texto de ayuda              │
//   └──────────────────────────────────────┘
//   Mensaje de error (solo cuando existe)
//
// El componente NO valida: el ViewModel decide qué mensaje mostrar y la
// pantalla lo entrega mediante `showError(_:)`.
//
// Uso:
//     let user = BiomaField(placeholder: "Usuario", icon: "person", helper: "Mínimo 4 caracteres")
//     let pass = BiomaField(placeholder: "Contraseña", icon: "lock", secure: true)
//     user.showError("El usuario es obligatorio")   // nil lo oculta
final class BiomaField: UIStackView {

    // MARK: - UI Components

    /// Expuesto para que la pantalla configure delegate, returnKeyType,
    /// textContentType y los eventos de edición.
    let input = UITextField()

    private let container = UIView()
    private let iconView = UIImageView()
    private let helperLabel = UILabel()
    private let errorLabel = UILabel()
    private let visibilityToggle = UIButton(type: .system)

    // MARK: - Init

    /// - Parameters:
    ///   - placeholder: Texto guía del campo; también se usa como etiqueta de accesibilidad.
    ///   - icon: SF Symbol opcional que se muestra a la izquierda.
    ///   - helper: Texto de ayuda opcional bajo el campo, por ejemplo «Mínimo 8 caracteres».
    ///   - secure: `true` para contraseñas; agrega el botón para mostrarlas u ocultarlas.
    init(placeholder: String, icon: String? = nil, helper: String? = nil, secure: Bool = false) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = BiomaTheme.Layout.fieldErrorSpacing
        translatesAutoresizingMaskIntoConstraints = false

        setupContainer()
        setupInput(placeholder: placeholder, secure: secure)
        setupErrorLabel()
        layoutContent(icon: icon, helper: helper, secure: secure)

        addArrangedSubview(container)
        addArrangedSubview(errorLabel)
    }

    required init(coder: NSCoder) { fatalError("Use init(placeholder:icon:helper:secure:)") }

    // MARK: - UI Setup

    /// Tarjeta clara con esquinas redondeadas y sombra suave.
    private func setupContainer() {
        container.backgroundColor = BiomaTheme.surface
        container.layer.cornerRadius = BiomaTheme.Layout.fieldCornerRadius
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.clear.cgColor
        BiomaTheme.applyCardShadow(to: container.layer)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(
            greaterThanOrEqualToConstant: BiomaTheme.Layout.fieldHeight
        ).isActive = true

        // Tocar cualquier parte de la tarjeta activa el campo, no solo el texto.
        container.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(focusInput))
        )
    }

    @objc private func focusInput() {
        input.becomeFirstResponder()
    }

    private func setupInput(placeholder: String, secure: Bool) {
        input.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: BiomaTheme.hint]
        )
        input.font = BiomaTheme.font(size: 16)
        input.adjustsFontForContentSizeCategory = true
        input.textColor = BiomaTheme.ink
        input.tintColor = BiomaTheme.forest          // Color del cursor.
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        input.isSecureTextEntry = secure
        input.accessibilityLabel = placeholder       // VoiceOver lee el nombre del campo.
        input.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    private func setupErrorLabel() {
        errorLabel.font = BiomaTheme.font(size: 12, relativeTo: .caption1)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.textColor = BiomaTheme.error
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
    }

    /// Distribuye icono, campo, ayuda y botón de visibilidad dentro de la tarjeta.
    private func layoutContent(icon: String?, helper: String?, secure: Bool) {
        // Columna central: campo de texto y, debajo, el texto de ayuda.
        let textColumn = UIStackView(arrangedSubviews: [input])
        textColumn.axis = .vertical
        textColumn.spacing = 2

        if let helper {
            helperLabel.text = helper
            helperLabel.font = BiomaTheme.font(size: 11, relativeTo: .caption2)
            helperLabel.adjustsFontForContentSizeCategory = true
            helperLabel.textColor = BiomaTheme.hint
            textColumn.addArrangedSubview(helperLabel)
        }

        // Fila completa: [icono] [columna de texto] [ojo].
        let row = UIStackView(arrangedSubviews: [textColumn])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.translatesAutoresizingMaskIntoConstraints = false

        if let icon {
            iconView.image = UIImage(systemName: icon)
            iconView.tintColor = BiomaTheme.deepForest
            iconView.contentMode = .scaleAspectFit
            iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            iconView.setContentHuggingPriority(.required, for: .horizontal)
            iconView.widthAnchor.constraint(equalToConstant: 26).isActive = true
            row.insertArrangedSubview(iconView, at: 0)
        }

        if secure {
            setupVisibilityToggle()
            row.addArrangedSubview(visibilityToggle)
        }

        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
    }

    /// Botón de ojo para mostrar u ocultar la contraseña.
    private func setupVisibilityToggle() {
        visibilityToggle.tintColor = BiomaTheme.ink
        visibilityToggle.addTarget(self, action: #selector(toggleVisibility), for: .touchUpInside)
        visibilityToggle.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            visibilityToggle.widthAnchor.constraint(equalToConstant: BiomaTheme.Layout.minimumTouchTarget),
            visibilityToggle.heightAnchor.constraint(equalToConstant: BiomaTheme.Layout.minimumTouchTarget)
        ])
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
        visibilityToggle.setImage(UIImage(systemName: hidden ? "eye.slash" : "eye"), for: .normal)
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
        container.layer.borderColor = (message == nil ? UIColor.clear : BiomaTheme.error).cgColor
        input.accessibilityHint = message
    }
}
