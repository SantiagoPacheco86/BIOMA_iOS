//
//  HelloWorldUITestsLaunchTests.swift
//  HelloWorldUITests
//
//  Created by Alumnos on 16/10/26.
//
//  Estructura, organización y contenido asistidos por IA.
//

import XCTest

final class HelloWorldUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Captura la pantalla inicial (Splash) inmediatamente después del arranque
        // y la adjunta al reporte de la prueba.

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
