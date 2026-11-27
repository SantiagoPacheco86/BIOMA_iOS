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
// (normal, presionado, deshabilitado) para que las pantallas solo cambien
// `isEnabled`, sin modificar `alpha` ni colores.
//
// El título se construye como texto atribuido, lo que permite anteponer un
// icono de SF Symbols sin recurrir a APIs obsoletas de UIButton.
//
// Uso:
//     let login  = BiomaButton("Ingresar")                                  // Primario
//     let photo  = BiomaButton("Tomar foto", icon: "camera")                // Primario con icono
//     let faceID = BiomaButton("Iniciar con Face ID", icon: "faceid", style: .outline)
//     let link   = BiomaButton(prompt: "¿No tienes una cuenta?", action: "Regístrate")
final class BiomaButton: UIButton {

    // MARK: - Style

    enum Style {
        /// Botón sólido verde con texto blanco.
        case primary
        /// Texto sin fondo para acciones secundarias o navegación.
        case link
        /// Contorno verde con fondo transparente y forma de cápsula.
        case outline
        /// Contorno blanco, pensado para colocarse sobre imágenes oscuras.
        case outlineLight
    }

    // MARK: - Properties

    private let style: Style
    private var titleText: String = ""
    private var iconName: String?

    /// Espacio horizontal interno de los estilos con contorno.
    private let horizontalPadding: CGFloat = 22

    // MARK: - Init

    init(_ title: String, icon: String? = nil, style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        configureAppearance()
        setTitle(title, icon: icon)
    }

    /// Enlace de dos líneas: una pregunta en gris seguida de la acción en verde.
    /// Ejemplo: «¿No tienes una cuenta?» / «Regístrate».
    convenience init(prompt: String, action: String) {
        self.init(action, style: .link)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 4

        let text = NSMutableAttributedString(
            string: prompt + "\n",
            attributes: [
                .foregroundColor: BiomaTheme.textSecondary,
                .font: BiomaTheme.font(size: 15, relativeTo: .subheadline),
                .paragraphStyle: paragraph
            ]
        )
        text.append(NSAttributedString(
            string: action,
            attributes: [
                .foregroundColor: BiomaTheme.deepForest,
                .font: BiomaTheme.font(size: 15, weight: .bold, relativeTo: .subheadline),
                .paragraphStyle: paragraph
            ]
        ))
        setAttributedTitle(text, for: .normal)
        accessibilityLabel = "\(prompt) \(action)"
    }

    /// Permite usar el componente desde código heredado; aplica el estilo primario.
    required init?(coder: NSCoder) {
        self.style = .primary
        super.init(coder: coder)
        configureAppearance()
    }

    // MARK: - Public API

    /// Cambia el texto y, opcionalmente, el icono del botón.
    /// - Parameters:
    ///   - title: Texto visible.
    ///   - icon: Nombre de un SF Symbol que se muestra antes del texto.
    func setTitle(_ title: String, icon: String? = nil) {
        titleText = title
        iconName = icon
        setAttributedTitle(makeAttributedTitle(), for: .normal)
        accessibilityLabel = title
        invalidateIntrinsicContentSize()
    }

    // MARK: - States

    // Cada vez que UIKit cambia el estado del botón se actualiza su opacidad.
    override var isEnabled: Bool {
        didSet { updateStateAppearance() }
    }

    override var isHighlighted: Bool {
        didSet { updateStateAppearance() }
    }

    // MARK: - Layout

    /// Los estilos con contorno añaden margen interno a su tamaño natural.
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        switch style {
        case .outline, .outlineLight:
            return CGSize(width: size.width + horizontalPadding * 2, height: size.height)
        case .primary, .link:
            return size
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Forma de cápsula: el radio depende de la altura final del botón.
        if style == .outline || style == .outlineLight {
            layer.cornerRadius = bounds.height / 2
        }
    }

    // MARK: - Appearance

    private func configureAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        layer.cornerCurve = .continuous

        switch style {
        case .primary:
            backgroundColor = BiomaTheme.forest
            layer.cornerRadius = BiomaTheme.Layout.buttonCornerRadius
            heightAnchor.constraint(
                greaterThanOrEqualToConstant: BiomaTheme.Layout.buttonHeight
            ).isActive = true

        case .link:
            backgroundColor = .clear
            heightAnchor.constraint(
                greaterThanOrEqualToConstant: BiomaTheme.Layout.minimumTouchTarget
            ).isActive = true

        case .outline:
            backgroundColor = .clear
            layer.borderWidth = 1.5
            layer.borderColor = BiomaTheme.forest.cgColor
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true

        case .outlineLight:
            backgroundColor = .clear
            layer.borderWidth = 1
            layer.borderColor = BiomaTheme.white.cgColor
            heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        }

        updateStateAppearance()
    }

    /// Fuente y color del título según el estilo.
    private var titleAttributes: (font: UIFont, color: UIColor) {
        switch style {
        case .primary:
            return (BiomaTheme.font(size: 17, weight: .bold, relativeTo: .headline), BiomaTheme.white)
        case .link:
            return (BiomaTheme.font(size: 15, weight: .semibold, relativeTo: .subheadline), BiomaTheme.deepForest)
        case .outline:
            return (BiomaTheme.font(size: 16, weight: .semibold, relativeTo: .headline), BiomaTheme.deepForest)
        case .outlineLight:
            return (BiomaTheme.font(size: 13, weight: .medium, relativeTo: .footnote), BiomaTheme.white)
        }
    }

    /// Construye el título con el icono opcional antepuesto.
    private func makeAttributedTitle() -> NSAttributedString {
        let (font, color) = titleAttributes
        let result = NSMutableAttributedString()

        if let iconName,
           let icon = UIImage(
                systemName: iconName,
                withConfiguration: UIImage.SymbolConfiguration(font: font)
           )?.withTintColor(color, renderingMode: .alwaysOriginal) {
            // El icono se inserta como un adjunto de texto, alineado con la línea base.
            let attachment = NSTextAttachment(image: icon)
            result.append(NSAttributedString(attachment: attachment))
            result.append(NSAttributedString(string: "  "))
        }

        result.append(NSAttributedString(string: titleText))
        result.addAttributes(
            [.font: font, .foregroundColor: color],
            range: NSRange(location: 0, length: result.length)
        )
        return result
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
