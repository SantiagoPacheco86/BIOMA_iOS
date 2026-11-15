//
//  BiomaButton.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 04/11/26.
//

import UIKit

// MARK: - BiomaButton
//
// Botón reutilizable de BIOMA. Encapsula la apariencia de cada estado
// (normal, presionado, deshabilitado) para que los ViewControllers solo
// tengan que cambiar `isEnabled`, sin tocar `alpha` ni colores.
//
// Uso:
//     let login = BiomaButton("Ingresar")                       // Primario
//     let link  = BiomaButton(prompt: "¿No tienes una cuenta?",
//                             action: "Regístrate")             // Enlace
final class BiomaButton: UIButton {

    // MARK: - Style

    enum Style {
        /// Botón sólido Forest con texto blanco. 52 pt de alto, radio 14.
        case primary
        /// Botón de texto, sin fondo, para acciones secundarias o navegación.
        case link
    }

    // MARK: - Properties

    private let style: Style

    // MARK: - Init

    init(_ title: String, style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        configureAppearance()
    }

    /// Enlace de dos tonos: una pregunta en Olive seguida de la acción en
    /// Forest y negrita. Ej.: «¿No tienes una cuenta? **Regístrate**».
    convenience init(prompt: String, action: String) {
        self.init(action, style: .link)

        let text = NSMutableAttributedString(
            string: prompt + " ",
            attributes: [
                .foregroundColor: BiomaTheme.olive,
                .font: BiomaTheme.font(size: 15, relativeTo: .subheadline)
            ]
        )
        text.append(NSAttributedString(
            string: action,
            attributes: [
                .foregroundColor: BiomaTheme.forest,
                .font: BiomaTheme.font(size: 15, weight: .bold, relativeTo: .subheadline)
            ]
        ))
        setAttributedTitle(text, for: .normal)
    }

    /// Permite usar el componente desde un Storyboard con estilo primario.
    required init?(coder: NSCoder) {
        self.style = .primary
        super.init(coder: coder)
        configureAppearance()
    }

    // MARK: - States

    // Cada vez que UIKit cambia el estado del botón actualizamos su opacidad.
    // Así el estado deshabilitado y la retroalimentación al presionar son
    // idénticos en todas las pantallas.
    override var isEnabled: Bool {
        didSet { updateStateAppearance() }
    }

    override var isHighlighted: Bool {
        didSet { updateStateAppearance() }
    }

    // MARK: - Appearance

    private func configureAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center

        switch style {
        case .primary:
            backgroundColor = BiomaTheme.forest
            setTitleColor(BiomaTheme.white, for: .normal)
            titleLabel?.font = BiomaTheme.font(size: 16, weight: .bold, relativeTo: .headline)
            layer.cornerRadius = BiomaTheme.Layout.buttonCornerRadius
            layer.cornerCurve = .continuous
            // `greaterThanOrEqual` mantiene los 52 pt de diseño, pero deja
            // crecer el botón si el usuario usa un tamaño de texto grande.
            heightAnchor.constraint(
                greaterThanOrEqualToConstant: BiomaTheme.Layout.buttonHeight
            ).isActive = true

        case .link:
            backgroundColor = .clear
            setTitleColor(BiomaTheme.forest, for: .normal)
            titleLabel?.font = BiomaTheme.font(size: 15, weight: .semibold, relativeTo: .subheadline)
            // Garantiza un área táctil cómoda aunque el texto sea pequeño.
            heightAnchor.constraint(
                greaterThanOrEqualToConstant: BiomaTheme.Layout.minimumTouchTarget
            ).isActive = true
        }

        updateStateAppearance()
    }

    private func updateStateAppearance() {
        if !isEnabled {
            alpha = BiomaTheme.Layout.disabledAlpha
        } else if isHighlighted {
            alpha = BiomaTheme.Layout.pressedAlpha
        } else {
            alpha = 1
        }
    }
}
