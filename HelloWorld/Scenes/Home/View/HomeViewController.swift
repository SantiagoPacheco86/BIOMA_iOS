//
//  HomeViewController.swift
//  HelloWorld
//
//  Created by Alumnos on 21/10/26.
//

import UIKit

// MARK: - HomeViewController
//
// Contenedor principal después del login: barra de pestañas con Inicio,
// Cámara y Perfil. Equivale a HomeActivity con su BottomNavigationView.
//
// Cada pestaña tiene su propio UINavigationController, de modo que las
// pantallas secundarias (Explorar, Historial, Mi información, Ayuda) se
// abren encima de la pestaña con flecha de regreso.
//
// SceneDelegate coloca esta pantalla como raíz de la ventana (no se hace push),
// por eso no es posible regresar al Login con el botón Atrás.
final class HomeViewController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
    }

    // MARK: - UI Setup

    /// Barra de pestañas clara con los colores de BIOMA.
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = BiomaTheme.surface
        appearance.shadowColor = BiomaTheme.divider

        // Misma apariencia en reposo y cuando el contenido llega al borde.
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        tabBar.tintColor = BiomaTheme.deepForest         // Pestaña seleccionada.
        tabBar.unselectedItemTintColor = BiomaTheme.hint // Pestañas en reposo.
    }

    // MARK: - Tabs

    /// Crea las tres pestañas en el mismo orden que el menú de Android.
    private func setupTabs() {
        let tabs = [
            makeTab(InicioViewController(), title: "Inicio", icon: "house"),
            makeTab(CameraViewController(), title: "Cámara", icon: "camera"),
            makeTab(ProfileViewController(), title: "Perfil", icon: "person")
        ]
        setViewControllers(tabs, animated: false)
    }

    /// Envuelve una pantalla en un UINavigationController y configura su pestaña.
    private func makeTab(_ rootViewController: UIViewController, title: String, icon: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: "\(icon).fill")
        )
        Self.applyBiomaStyle(to: navigationController.navigationBar)
        return navigationController
    }

    /// Barra de navegación del color del fondo, sin línea inferior y con la
    /// flecha de regreso en verde. Se comparte con el flujo de autenticación.
    static func applyBiomaStyle(to navigationBar: UINavigationBar, transparent: Bool = false) {
        let appearance = UINavigationBarAppearance()
        if transparent {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = BiomaTheme.background
            appearance.shadowColor = .clear
        }
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = BiomaTheme.deepForest
    }
}
