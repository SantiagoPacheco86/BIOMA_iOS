//
//  BiomaSpeciesRow.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - BiomaSpeciesRow
//
// Tarjeta horizontal de una especie o detección:
//
//   ┌──────────────────────────────────────────────┐
//   │ [foto]  Quercus mexicana                   › │
//   │         Encino mexicano                      │
//   │         🍃 Planta   (o la fecha)             │
//   └──────────────────────────────────────────────┘
//
// Se usa en Historial y en «Otras coincidencias» de Explorar.
final class BiomaSpeciesRow: UIControl {

    // MARK: - UI Components

    /// Expuesta para mostrar una foto local o remota.
    let photoView = BiomaRemoteImageView(cornerRadius: 12)

    private let card = BiomaCardView()
    private let titleLabel = BiomaLabel(style: .cardTitle)
    private let subtitleLabel = BiomaLabel(style: .body)
    private let footerIcon = UIImageView()
    private let footerLabel = BiomaLabel(style: .caption)
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityTraits = .button
        isAccessibilityElement = true

        card.isUserInteractionEnabled = false
        addSubview(card)

        titleLabel.numberOfLines = 2
        footerLabel.textColor = BiomaTheme.ink
        footerIcon.tintColor = BiomaTheme.ink
        footerIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11)
        chevron.tintColor = BiomaTheme.ink
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let footer = UIStackView(arrangedSubviews: [footerIcon, footerLabel])
        footer.axis = .horizontal
        footer.spacing = 6
        footer.alignment = .center

        let texts = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, footer])
        texts.axis = .vertical
        texts.spacing = 4
        texts.setCustomSpacing(8, after: subtitleLabel)

        let row = UIStackView(arrangedSubviews: [photoView, texts, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 16

        card.embed(row, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 18))

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoView.widthAnchor.constraint(equalToConstant: 76),
            photoView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }

    required init?(coder: NSCoder) { fatalError("Use init()") }

    // MARK: - Public API

    /// Configura los textos de la fila.
    /// - Parameters:
    ///   - title: Nombre científico.
    ///   - subtitle: Nombre común.
    ///   - footer: Texto inferior (tipo de organismo o fecha).
    ///   - footerIcon: SF Symbol opcional junto al texto inferior.
    ///   - showsChevron: Indica si se muestra la flecha de acción.
    func configure(title: String, subtitle: String, footer: String, footerIcon: String? = nil, showsChevron: Bool = true) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        footerLabel.text = footer
        self.footerIcon.image = footerIcon.flatMap { UIImage(systemName: $0) }
        self.footerIcon.isHidden = footerIcon == nil
        chevron.isHidden = !showsChevron
        accessibilityLabel = "\(title), \(subtitle), \(footer)"
    }

    // MARK: - States

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? BiomaTheme.Layout.pressedAlpha : 1 }
    }
}
