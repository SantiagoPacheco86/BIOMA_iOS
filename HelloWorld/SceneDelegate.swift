//
//  SceneDelegate.swift
//  HelloWorld
//
//  Created by Alumnos on 16/10/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?



    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        // MARK: - 1. VALIDAR ESCENA

        // Verificamos que la escena sea una ventana de iOS.
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        // MARK: - 2. CREAR VENTANA

        // Creamos la ventana principal asociada a la escena.
        let window = UIWindow(windowScene: windowScene)

        // Conservamos la ventana en SceneDelegate.
        self.window = window

        // MARK: - 3. DEFINIR PANTALLA INICIAL

        // La app comienza con el Splash, que a los 2.5 segundos da paso al Login.
        showSplash()

        // MARK: - 4. MOSTRAR PANTALLA

        // Hacemos visible la interfaz.
        window.makeKeyAndVisible()
    }

    // MARK: - Navegación raíz
    //
    // La app tiene dos "mundos" que no deben mezclarse en una misma pila:
    //
    //   • Autenticación: Splash → UINavigationController → Main ⇄ Register
    //   • Sesión iniciada: HomeViewController (pestañas Inicio, Cámara y Perfil)
    //
    // En lugar de hacer push de Home sobre el Login, reemplazamos la
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


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

