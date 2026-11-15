//
//  BiomaAvatarView.swift
//  HelloWorld
//

import UIKit

// MARK: - BiomaAvatarView
//
// Foto de perfil circular con un aro discreto y un botón de cámara en la
// esquina inferior derecha, como en las pantallas Perfil y Mi información.
//
// Uso:
//     let avatar = BiomaAvatarView(diameter: 150)
//     avatar.badgeButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
//     avatar.setImage(foto)   // nil muestra el círculo vacío
final class BiomaAvatarView: UIView {

    // MARK: - UI Components

    private let imageView = UIImageView()

    /// Botón circular de cámara; la pantalla decide qué hace al tocarlo.
    let badgeButton = UIButton(type: .custom)

    // MARK: - Init

    init(diameter: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        // Foto circular con aro gris claro.
        imageView.backgroundColor = BiomaTheme.authBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = diameter / 2
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = BiomaTheme.border.cgColor
        imageView.isAccessibilityElement = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        // Botón de cámara superpuesto, proporcional al tamaño del avatar.
        let badgeSize = max(44, diameter * 0.3)
        badgeButton.backgroundColor = BiomaTheme.deepForest
        badgeButton.tintColor = BiomaTheme.white
        badgeButton.setImage(
            UIImage(
                systemName: "camera",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: badgeSize * 0.38, weight: .medium)
            ),
            for: .normal
        )
        badgeButton.layer.cornerRadius = badgeSize / 2
        badgeButton.layer.borderWidth = 3
        badgeButton.layer.borderColor = BiomaTheme.background.cgColor
        BiomaTheme.applyCardShadow(to: badgeButton.layer)
        badgeButton.accessibilityLabel = "Cambiar foto de perfil"
        badgeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeButton)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: diameter),
            heightAnchor.constraint(equalToConstant: diameter),

            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            badgeButton.widthAnchor.constraint(equalToConstant: badgeSize),
            badgeButton.heightAnchor.constraint(equalToConstant: badgeSize),
            badgeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: badgeSize * 0.05),
            badgeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -diameter * 0.02)
        ])

        setImage(nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(diameter:)") }

    // MARK: - Public API

    /// Muestra la foto de perfil; `nil` deja el círculo vacío.
    func setImage(_ image: UIImage?) {
        imageView.image = image
        imageView.accessibilityLabel = image == nil ? "Sin foto de perfil" : "Foto de perfil"
    }
}
