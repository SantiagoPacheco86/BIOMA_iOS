//
//  BiomaViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - BiomaViewController
//
// Controlador base de las pantallas de BIOMA, equivalente al BaseActivity del
// proyecto Android. Centraliza lo que todas las pantallas comparten:
//
//   • Color de fondo.
//   • Barra de navegación: oculta en la pantalla raíz de cada pestaña (que ya
//     tiene su propio encabezado) y visible en las pantallas abiertas encima,
//     para mostrar la flecha de regreso.
//   • Contenido desplazable: un UIScrollView con un UIStackView vertical
//     (`contentStack`) que respeta los márgenes de BIOMA y el teclado.
//   • Alertas y avisos breves.
class BiomaViewController: UIViewController {

    // MARK: - UI Components

    /// Contenedor desplazable de la pantalla.
    let scrollView = UIScrollView()

    /// Pila vertical donde cada pantalla agrega sus elementos.
    let contentStack = UIStackView()

    // MARK: - Configuration

    /// Color de fondo de la pantalla. Las subclases pueden cambiarlo.
    var screenBackgroundColor: UIColor { BiomaTheme.background }

    /// La barra se oculta cuando la pantalla es la primera de su pila de navegación.
    var hidesNavigationBar: Bool {
        navigationController?.viewControllers.first === self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = screenBackgroundColor
        // Texto vacío en el botón de regreso de las pantallas siguientes: solo la flecha.
        navigationItem.backButtonDisplayMode = .minimal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hidesNavigationBar, animated: animated)
    }

    // MARK: - Scrollable Content

    /// Agrega el contenido desplazable ocupando toda la pantalla.
    /// - Parameters:
    ///   - spacing: Separación vertical por defecto entre los elementos.
    ///   - topInset: Margen superior del contenido.
    func setupScrollableContent(spacing: CGFloat = BiomaTheme.Layout.spacing, topInset: CGFloat = 16) {
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = spacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        let margin = BiomaTheme.Layout.horizontalMargin

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // El área visible termina donde empieza el teclado.
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: topInset),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: margin),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -margin),
            // El ancho fijo al marco evita el desplazamiento horizontal.
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -margin * 2)
        ])
    }

    // MARK: - Layout Helpers

    /// Envuelve una vista para centrarla horizontalmente dentro de `contentStack`,
    /// que estira a sus elementos a todo el ancho.
    func centered(_ view: UIView) -> UIView {
        let wrapper = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: wrapper.topAnchor),
            view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            view.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: wrapper.leadingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor)
        ])
        return wrapper
    }

    /// Imagen de fondo de montañas que ocupa toda la pantalla, detrás del contenido.
    /// Debe llamarse antes de `setupScrollableContent()`.
    func addMountainBackground() {
        let background = UIImageView(image: UIImage(named: "BiomaBackground"))
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        background.isAccessibilityElement = false
        background.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Navigation

    /// Abre una pantalla encima de la actual dentro de la pestaña.
    func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Messages

    /// Presenta una alerta informativa con un único botón de confirmación.
    func showAlert(title: String, message: String, buttonTitle: String = "Aceptar", onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in onDismiss?() })
        present(alert, animated: true)
    }

    /// Muestra un aviso breve en la parte inferior de la pantalla.
    func showToast(_ message: String) {
        BiomaToast.show(message, in: view)
    }
}
