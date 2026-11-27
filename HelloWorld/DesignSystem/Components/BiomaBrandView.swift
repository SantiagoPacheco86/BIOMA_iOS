//
//  BiomaBrandView.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - BiomaBrandView
//
// Identidad de BIOMA: logotipo, nombre «BIOMA» (con la «O» en tono arena)
// y el lema «EXPLORA · IDENTIFICA · CONOCE».
//
// Dos variantes:
//   • .large / .medium → vertical y centrada (Splash, Login, Registro).
//   • .compact         → horizontal, para el encabezado de las pantallas internas.
//
// Uso:
//     let brand = BiomaBrandView(size: .large)
final class BiomaBrandView: UIStackView {

    // MARK: - Size

    enum Size {
        case large
        case medium
        case compact

        fileprivate var logoSize: CGFloat {
            switch self {
            case .large:   return 115
            case .medium:  return 100
            case .compact: return 44
            }
        }

        fileprivate var nameFontSize: CGFloat {
            switch self {
            case .large:   return 32
            case .medium:  return 28
            case .compact: return 19
            }
        }

        fileprivate var taglineFontSize: CGFloat {
            switch self {
            case .large, .medium: return 9
            case .compact:        return 7.5
            }
        }

        /// Separación entre letras del nombre, como en el logotipo original.
        fileprivate var nameKerning: CGFloat {
            switch self {
            case .large, .medium: return 8
            case .compact:        return 4
            }
        }
    }

    // MARK: - Init

    init(size: Size) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityLabel = "BIOMA. Explora, identifica, conoce."
        accessibilityTraits = .header

        let logo = UIImageView(image: UIImage(named: "BiomaLogo"))
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: size.logoSize),
            logo.heightAnchor.constraint(equalToConstant: size.logoSize)
        ])

        let name = UILabel()
        name.attributedText = Self.makeName(fontSize: size.nameFontSize, kerning: size.nameKerning)

        let tagline = UILabel()
        tagline.attributedText = NSAttributedString(
            string: "EXPLORA · IDENTIFICA · CONOCE",
            attributes: [
                .font: UIFont.systemFont(ofSize: size.taglineFontSize, weight: .bold),
                .foregroundColor: BiomaTheme.deepForest,
                .kern: 1.6
            ]
        )

        // Nombre y lema siempre van juntos, uno sobre otro.
        let texts = UIStackView(arrangedSubviews: [name, tagline])
        texts.axis = .vertical
        texts.spacing = size == .compact ? 2 : 6

        switch size {
        case .large, .medium:
            axis = .vertical
            alignment = .center
            spacing = 10
            texts.alignment = .center
        case .compact:
            axis = .horizontal
            alignment = .center
            spacing = 10
            texts.alignment = .leading
        }

        addArrangedSubview(logo)
        addArrangedSubview(texts)
    }

    required init(coder: NSCoder) { fatalError("Use init(size:)") }

    // MARK: - Helpers

    /// «BIOMA» en verde profundo con la «O» en tono arena.
    private static func makeName(fontSize: CGFloat, kerning: CGFloat) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .heavy)
        let result = NSMutableAttributedString()
        for letter in "BIOMA" {
            let color = letter == "O" ? BiomaTheme.taupe : BiomaTheme.deepForest
            result.append(NSAttributedString(
                string: String(letter),
                attributes: [.font: font, .foregroundColor: color, .kern: kerning]
            ))
        }
        return result
    }
}

// MARK: - BiomaHeaderView
//
// Encabezado de las pantallas internas: logotipo compacto a la izquierda y,
// a la derecha, un título («Perfil», «Explorar»…) o un control (campana,
// enlace «Historial»).
//
// Uso:
//     let header = BiomaHeaderView(title: "Perfil")
//     let header = BiomaHeaderView(accessory: historyButton)
final class BiomaHeaderView: UIStackView {

    // MARK: - Init

    /// Encabezado con un título de texto a la derecha.
    convenience init(title: String) {
        let label = BiomaLabel(title, style: .sectionTitle)
        label.font = BiomaTheme.font(size: 24, weight: .bold, relativeTo: .title2)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        self.init(accessory: label)
    }

    /// Encabezado con cualquier vista a la derecha (o ninguna).
    init(accessory: UIView? = nil) {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        spacing = 12
        translatesAutoresizingMaskIntoConstraints = false

        let brand = BiomaBrandView(size: .compact)
        brand.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addArrangedSubview(brand)

        // Espaciador flexible que empuja el accesorio hacia la derecha.
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addArrangedSubview(spacer)

        if let accessory {
            accessory.setContentCompressionResistancePriority(.required, for: .horizontal)
            addArrangedSubview(accessory)
        }
    }

    required init(coder: NSCoder) { fatalError("Use init(title:) o init(accessory:)") }
}
