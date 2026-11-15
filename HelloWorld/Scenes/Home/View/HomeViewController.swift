//
//  HomeViewController.swift
//  HelloWorld
//
//  Created by Alumnos on 21/10/26.
//

import UIKit

// MARK: - HomeViewController
//
// Pantalla principal después del login. Es un UITabBarController:
// cada pestaña es un UINavigationController con su propia pantalla raíz.
// SceneDelegate la coloca como raíz de la ventana (no se hace push), por
// eso no existe una barra de navegación externa ni regreso al Login.
final class HomeViewController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
    }

    // MARK: - UI Setup

    /// Aplica la identidad visual de BIOMA al tab bar.
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = BiomaTheme.background

        // Misma apariencia en reposo y cuando el contenido llega al borde.
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        tabBar.tintColor = BiomaTheme.forest            // Pestaña seleccionada.
        tabBar.unselectedItemTintColor = BiomaTheme.hint // Pestañas en reposo.
    }

    // MARK: - Tabs

    /// Crea las pestañas y se las entrega al tab bar.
    private func setupTabs() {
        // List y Profile todavía se construyen desde sus storyboards.
        let listVC = UIStoryboard(name: "List", bundle: nil)
            .instantiateViewController(identifier: "ListViewController") { coder in
                ListViewController(coder: coder)
            }

        let profileVC = UIStoryboard(name: "Profile", bundle: nil)
            .instantiateViewController(identifier: "ProfileViewController") { coder in
                ProfileViewController(coder: coder)
            }

        let listTab = createNavController(
            for: listVC,
            title: "List",
            image: UIImage(systemName: "list.bullet")
        )
        let profileTab = createNavController(
            for: profileVC,
            title: "Profile",
            image: UIImage(systemName: "person.fill")
        )

        // Sin esta línea el tab bar no tiene contenido y se ve vacío.
        setViewControllers([listTab, profileTab], animated: false)
    }

    /// Envuelve una pantalla en un UINavigationController y configura su pestaña.
    private func createNavController(
        for rootVC: UIViewController,
        title: String,
        image: UIImage?
    ) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootVC)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.tintColor = BiomaTheme.forest

        // Título que aparece en la barra de navegación de la pestaña.
        rootVC.navigationItem.title = title
        rootVC.view.backgroundColor = BiomaTheme.background
        return navController
    }
}
