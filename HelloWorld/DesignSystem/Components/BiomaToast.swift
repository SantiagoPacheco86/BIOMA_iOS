//
//  BiomaToast.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - BiomaToast
//
// Aviso breve en la parte inferior de la pantalla que desaparece solo.
// Equivale al Snackbar de Android («Detección guardada», «Contraseña actualizada»).
//
// Uso:
//     BiomaToast.show("Detección guardada", in: view)
enum BiomaToast {

    /// Muestra un mensaje durante unos segundos sobre la vista indicada.
    /// - Parameters:
    ///   - message: Texto del aviso.
    ///   - view: Vista sobre la que aparece (normalmente `view` del controlador).
    ///   - duration: Tiempo visible, en segundos.
    static func show(_ message: String, in view: UIView, duration: TimeInterval = 2.2) {
        let label = UILabel()
        label.text = message
        label.textColor = BiomaTheme.white
        label.font = BiomaTheme.font(size: 15, weight: .medium, relativeTo: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = BiomaTheme.ink.withAlphaComponent(0.95)
        container.layer.cornerRadius = 12
        container.layer.cornerCurve = .continuous
        container.alpha = 0
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),

            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        // VoiceOver anuncia el mensaje aunque no tenga el foco.
        UIAccessibility.post(notification: .announcement, argument: message)

        UIView.animate(withDuration: 0.25) {
            container.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: duration) {
                container.alpha = 0
            } completion: { _ in
                container.removeFromSuperview()
            }
        }
    }
}
