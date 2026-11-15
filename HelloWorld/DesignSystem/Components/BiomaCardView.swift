//
//  BiomaCardView.swift
//  HelloWorld
//

import UIKit

// MARK: - BiomaCardView
//
// Tarjeta clara con esquinas redondeadas y sombra suave: el contenedor base
// de casi todos los bloques de BIOMA (filas de perfil, consejos, resultados).
//
// Uso:
//     let card = BiomaCardView(content: miStackView)
class BiomaCardView: UIView {

    // MARK: - Init

    /// - Parameters:
    ///   - content: Vista que se coloca dentro de la tarjeta.
    ///   - insets: Margen interno entre el borde de la tarjeta y su contenido.
    init(content: UIView? = nil, insets: UIEdgeInsets = .zero) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BiomaTheme.surface
        layer.cornerRadius = BiomaTheme.Layout.cardCornerRadius
        layer.cornerCurve = .continuous
        BiomaTheme.applyCardShadow(to: layer)

        if let content {
            embed(content, insets: insets)
        }
    }

    required init?(coder: NSCoder) { fatalError("Use init(content:insets:)") }

    // MARK: - Public API

    /// Coloca una vista dentro de la tarjeta respetando el margen indicado.
    func embed(_ content: UIView, insets: UIEdgeInsets) {
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
        ])
    }
}

// MARK: - BiomaListRow
//
// Fila tocable: icono, título, subtítulo opcional y flecha «›».
// Se usa en Perfil («Mi información», «Ayuda») y en Mi información.
//
// Uso:
//     let row = BiomaListRow(icon: "person", title: "Nombre", subtitle: "Santiago")
//     row.addTarget(self, action: #selector(editName), for: .touchUpInside)
final class BiomaListRow: UIControl {

    // MARK: - UI Components

    private let iconView = UIImageView()
    private let titleLabel = BiomaLabel(style: .cardTitle)
    private let subtitleLabel = BiomaLabel(style: .body)
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    // MARK: - Properties

    /// Texto secundario de la fila; `nil` o vacío lo oculta.
    var subtitle: String? {
        didSet { updateSubtitle() }
    }

    // MARK: - Init

    init(icon: String, title: String, subtitle: String? = nil, showsChevron: Bool = true) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityTraits = .button

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = BiomaTheme.deepForest
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)

        titleLabel.text = title
        chevron.tintColor = BiomaTheme.ink
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        chevron.isHidden = !showsChevron

        let texts = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        texts.axis = .vertical
        texts.spacing = 4

        let row = UIStackView(arrangedSubviews: [iconView, texts, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 18
        row.isUserInteractionEnabled = false   // Los toques los recibe la fila completa.
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        iconView.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])

        self.subtitle = subtitle
        updateSubtitle()
    }

    required init?(coder: NSCoder) { fatalError("Use init(icon:title:subtitle:showsChevron:)") }

    // MARK: - States

    /// Retroalimentación visual al presionar la fila.
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? BiomaTheme.divider.withAlphaComponent(0.5) : .clear }
    }

    // MARK: - Helpers

    private func updateSubtitle() {
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle ?? "").isEmpty
        accessibilityLabel = [titleLabel.text, subtitle].compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - BiomaRowGroup
//
// Tarjeta que agrupa varias filas separadas por líneas finas, como las
// secciones «Información personal» o «Cuenta».
final class BiomaRowGroup: BiomaCardView {

    init(rows: [UIView]) {
        super.init()
        clipsToBounds = false

        let stack = UIStackView()
        stack.axis = .vertical

        for (index, row) in rows.enumerated() {
            if index > 0 {
                stack.addArrangedSubview(Self.makeDivider())
            }
            stack.addArrangedSubview(row)
        }
        embed(stack, insets: .zero)
    }

    required init?(coder: NSCoder) { fatalError("Use init(rows:)") }

    /// Línea separadora con margen lateral.
    private static func makeDivider() -> UIView {
        let wrapper = UIView()
        let line = UIView()
        line.backgroundColor = BiomaTheme.divider
        line.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(line)
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1),
            line.topAnchor.constraint(equalTo: wrapper.topAnchor),
            line.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            line.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20)
        ])
        return wrapper
    }
}

// MARK: - BiomaPill
//
// Etiqueta en forma de píldora con icono opcional: «Planta», «Usuario
// estándar», «Bioma v1.0.0» o el contador de detecciones.
final class BiomaPill: UIView {

    // MARK: - UI Components

    private let iconView = UIImageView()
    private let label = UILabel()

    // MARK: - Properties

    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            accessibilityLabel = newValue
        }
    }

    // MARK: - Init

    /// - Parameters:
    ///   - text: Contenido de la etiqueta.
    ///   - icon: SF Symbol opcional a la izquierda del texto.
    ///   - fontSize: Tamaño del texto.
    ///   - background: Color de fondo de la píldora.
    init(_ text: String, icon: String? = nil, fontSize: CGFloat = 13, background: UIColor = BiomaTheme.pill) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = background
        layer.cornerCurve = .continuous
        isAccessibilityElement = true

        label.font = BiomaTheme.font(size: fontSize, relativeTo: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = BiomaTheme.ink
        self.text = text

        let stack = UIStackView(arrangedSubviews: [label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        if let icon {
            iconView.image = UIImage(systemName: icon)
            iconView.tintColor = BiomaTheme.ink
            iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: fontSize - 1)
            stack.insertArrangedSubview(iconView, at: 0)
        }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) { fatalError("Use init(_:icon:fontSize:background:)") }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

// MARK: - BiomaInfoCard
//
// Tarjeta informativa sin acción: icono dentro de un círculo menta, título y
// descripción. Se usa en los consejos de la pantalla de Ayuda.
final class BiomaInfoCard: BiomaCardView {

    init(icon: String, title: String, message: String) {
        super.init()

        let iconCircle = UIView()
        iconCircle.backgroundColor = BiomaTheme.mint
        iconCircle.layer.cornerRadius = 28
        iconCircle.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = BiomaTheme.deepForest
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)

        let titleLabel = BiomaLabel(title, style: .cardTitle)
        let messageLabel = BiomaLabel(message, style: .body)

        let texts = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        texts.axis = .vertical
        texts.spacing = 4

        let row = UIStackView(arrangedSubviews: [iconCircle, texts])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 18

        NSLayoutConstraint.activate([
            iconCircle.widthAnchor.constraint(equalToConstant: 56),
            iconCircle.heightAnchor.constraint(equalToConstant: 56),
            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor)
        ])

        embed(row, insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        isAccessibilityElement = true
        accessibilityLabel = "\(title). \(message)"
    }

    required init?(coder: NSCoder) { fatalError("Use init(icon:title:message:)") }
}
