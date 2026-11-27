//
//  AppDelegate.swift
//  HelloWorld
//
//  Created by Alumnos on 16/10/26.
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - AppDelegate
//
// Punto de entrada de la aplicación (`@main`). Atiende los eventos globales del
// proceso y le indica a iOS qué configuración de escena utilizar. La creación
// de la ventana y de las pantallas corresponde a SceneDelegate.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Se ejecuta una sola vez al terminar el lanzamiento de la app.
    /// BIOMA no requiere configuración global en este punto.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // iOS solicita la configuración al crear una escena nueva. «Default Configuration»
        // está declarada en Info.plist y asigna SceneDelegate como delegado de la escena.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // iOS notifica las escenas que el usuario descartó desde el selector de apps.
        // BIOMA utiliza una sola escena y no conserva recursos asociados a ellas.
    }
}

