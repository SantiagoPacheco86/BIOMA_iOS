//
//  SceneDelegate.swift
//  HelloWorld
//
//  Created by Alumnos on 16/10/26.
//

import UIKit

// MARK: - SceneDelegate
//
// Administra la ventana de la aplicación y decide qué pantalla es la raíz:
// Splash al arrancar, Login sin sesión y Home con sesión iniciada.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// Ventana principal; SceneDelegate la conserva mientras la escena existe.
    var window: UIWindow?

    /// iOS llama a este método al conectar la escena: es el inicio visual de la app.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        // MARK: - 1. VALIDAR ESCENA

        // La escena debe ser una ventana de iOS (UIWindowScene).
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        // MARK: - 2. CREAR VENTANA

        // Ventana principal asociada a la escena.
        let window = UIWindow(windowScene: windowScene)

        // SceneDelegate conserva la ventana para que no se libere.
        self.window = window

        // MARK: - 3. DEFINIR PANTALLA INICIAL

        // La app comienza con el Splash, que a los 2.5 segundos da paso al Login.
        showSplash()

        // MARK: - 4. MOSTRAR PANTALLA

        // La ventana se convierte en la principal y se hace visible.
        window.makeKeyAndVisible()
    }

    // MARK: - Navegación raíz
    //
    // La app tiene dos "mundos" que no deben mezclarse en una misma pila:
    //
    //   • Autenticación: Splash → UINavigationController → Main ⇄ Register
    //   • Sesión iniciada: HomeViewController (pestañas Inicio, Cámara y Perfil)
    //
    // En lugar de hacer push de Home sobre el Login, se reemplaza la
    // pantalla raíz de la ventana. Así el Login se libera de memoria y el
    // botón Atrás (o el gesto de deslizar) no puede regresar a él.

    /// Muestra la pantalla de bienvenida y, al terminar, el Login.
    func showSplash() {
        let splash = SplashViewController { [weak self] in
            self?.showLogin()
        }
        setRootViewController(splash, animated: false)
    }

    /// Muestra el flujo de autenticación (Login → Registro).
    /// Se usa después del Splash y al cerrar sesión.
    func showLogin(animated: Bool = true) {
        let navigationController = UINavigationController(
            rootViewController: MainViewController()
        )
        // Barra transparente: el fondo de montañas se ve también detrás de la flecha.
        HomeViewController.applyBiomaStyle(to: navigationController.navigationBar, transparent: true)

        setRootViewController(navigationController, animated: animated)
    }

    /// Cierra la sesión actual y regresa al Login.
    func logout() {
        UserStore.shared.logout()
        showLogin()
    }

    /// Muestra la pantalla principal después de un login exitoso.
    func showHome(animated: Bool = true) {
        setRootViewController(HomeViewController(), animated: animated)
    }

    /// Reemplaza la pantalla raíz de la ventana, con un fundido opcional.
    private func setRootViewController(_ viewController: UIViewController, animated: Bool) {
        guard let window else { return }

        window.rootViewController = viewController

        guard animated else { return }
        // Fundido cruzado suave entre la pantalla anterior y la nueva.
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }


    // MARK: - Ciclo de vida de la escena
    //
    // iOS llama a estos métodos cuando la escena cambia de estado. BIOMA guarda
    // sus datos en el momento en que se modifican (UserDefaults, Keychain y
    // archivos), por lo que no necesita trabajo adicional en ninguna transición.

    /// La escena se libera; puede volver a conectarse más tarde.
    func sceneDidDisconnect(_ scene: UIScene) {}

    /// La escena pasa a primer plano y recibe interacción.
    func sceneDidBecomeActive(_ scene: UIScene) {}

    /// La escena deja de estar activa, por ejemplo durante una llamada entrante.
    func sceneWillResignActive(_ scene: UIScene) {}

    /// La escena regresa del segundo plano.
    func sceneWillEnterForeground(_ scene: UIScene) {}

    /// La escena pasa al segundo plano.
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

