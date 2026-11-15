//
//  BiomaLabel.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 04/11/26.
//

import UIKit

// MARK: - BiomaLabel
//
// Etiqueta con la jerarquía tipográfica oficial de BIOMA (sección 3.1).
// En lugar de pasar tamaño, peso y color en cada pantalla, se elige un
// estilo semántico; así todas las pantallas se ven consistentes.
//
// Uso:
//     let title = BiomaLabel("Crea tu cuenta", style: .title)
//     let subtitle = BiomaLabel("Comienza a explorar…", style: .body)
final class BiomaLabel: UILabel {

    // MARK: - Style

    enum Style {
        /// Nombre «BIOMA». 34 pt Bold, Forest, centrado.
        case brand
        /// Lema «EXPLORA · IDENTIFICA · CONOCE». 12 pt Semibold, Olive, centrado.
        case tagline
        /// Título principal de pantalla. 28 pt Bold, Ink.
        case title
        /// Título de sección. 22 pt Semibold, Ink.
        case sectionTitle
        /// Encabezado de bloque dentro de una pantalla. 18 pt Bold, Ink.
        case headline
        /// Título de una tarjeta o fila. 16 pt Semibold, Ink.
        case cardTitle
        /// Texto descriptivo o secundario. 14 pt Regular, gris.
        case body
        /// Texto auxiliar pequeño. 12 pt Regular, Hint.
        case caption

        fileprivate var font: UIFont {
            switch self {
            case .brand:        return BiomaTheme.font(size: 34, weight: .bold, relativeTo: .largeTitle)
            case .tagline:      return BiomaTheme.font(size: 12, weight: .semibold, relativeTo: .caption1)
            case .title:        return BiomaTheme.font(size: 28, weight: .bold, relativeTo: .title1)
            case .sectionTitle: return BiomaTheme.font(size: 22, weight: .semibold, relativeTo: .title2)
            case .headline:     return BiomaTheme.font(size: 18, weight: .bold, relativeTo: .headline)
            case .cardTitle:    return BiomaTheme.font(size: 16, weight: .semibold, relativeTo: .headline)
            case .body:         return BiomaTheme.font(size: 14, relativeTo: .subheadline)
            case .caption:      return BiomaTheme.font(size: 12, relativeTo: .caption1)
            }
        }

        fileprivate var color: UIColor {
            switch self {
            case .brand:                                      return BiomaTheme.forest
            case .tagline:                                    return BiomaTheme.olive
            case .body:                                       return BiomaTheme.textSecondary
            case .title, .sectionTitle, .headline, .cardTitle: return BiomaTheme.ink
            case .caption:                                    return BiomaTheme.hint
            }
        }

        fileprivate var alignment: NSTextAlignment {
            switch self {
            case .brand, .tagline: return .center
            default:               return .natural
            }
        }

        /// Los títulos se anuncian como encabezados en VoiceOver para
        /// que el usuario pueda saltar entre secciones con el rotor.
        fileprivate var isHeader: Bool {
            switch self {
            case .brand, .title, .sectionTitle, .headline: return true
            default:                                       return false
            }
        }
    }

    // MARK: - Init

    init(_ text: String? = nil, style: Style = .body) {
        super.init(frame: .zero)
        self.text = text
        apply(style)
    }

    /// Permite usar el componente desde un Storyboard; aplica el estilo `.body`.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        apply(.body)
    }

    // MARK: - Styling

    /// Cambia el estilo después de crear la etiqueta, si fuera necesario.
    func apply(_ style: Style) {
        font = style.font
        textColor = style.color
        textAlignment = style.alignment
        numberOfLines = 0                         // Permite varias líneas en pantallas pequeñas.
        adjustsFontForContentSizeCategory = true  // Reacciona a Dynamic Type en vivo.
        accessibilityTraits = style.isHeader ? .header : .staticText
    }
}
