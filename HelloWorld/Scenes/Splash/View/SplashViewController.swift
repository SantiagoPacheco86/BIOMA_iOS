//
//  SplashViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - SplashViewController
//
// Pantalla de bienvenida: fondo de montañas y logotipo de BIOMA.
// Después de 2.5 segundos da paso al Login, igual que SplashActivity en Android.
final class SplashViewController: BiomaViewController {

    // MARK: - Constants

    /// Tiempo que permanece visible la pantalla, en segundos.
    private let displayDuration: TimeInterval = 2.5

    // MARK: - Properties

    /// Acción que se ejecuta al terminar; la define SceneDelegate.
    private let onFinish: () -> Void

    override var screenBackgroundColor: UIColor { BiomaTheme.authBackground }

    // MARK: - Init

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(onFinish:)") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCountdown()
    }

    // MARK: - UI Setup

    private func setupUI() {
        addMountainBackground()

        let brand = BiomaBrandView(size: .large)
        view.addSubview(brand)
        NSLayoutConstraint.activate([
            brand.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Ligeramente por encima del centro, como en el diseño Android.
            brand.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30)
        ])
    }

    // MARK: - Navigation

    /// Espera el tiempo de la pantalla y continúa al Login.
    private func startCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) { [weak self] in
            self?.onFinish()
        }
    }
}
