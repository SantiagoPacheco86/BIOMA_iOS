//
//  HelloWorldUITests.swift
//  HelloWorldUITests
//
//  Created by Alumnos on 16/10/26.
//
//  Estructura, organización y contenido asistidos por IA.
//

import XCTest

final class HelloWorldUITests: XCTestCase {

    override func setUpWithError() throws {
        // Se ejecuta antes de cada prueba. La prueba se detiene en el primer fallo,
        // ya que en las pruebas de interfaz los pasos siguientes dependen de los anteriores.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Se ejecuta después de cada prueba; no hay recursos que liberar.
    }

    @MainActor
    func testExample() throws {
        // Las pruebas de interfaz lanzan la aplicación que verifican.
        let app = XCUIApplication()
        app.launch()

        // Las verificaciones de esta prueba de ejemplo se expresarían con XCTAssert.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // Mide el tiempo de arranque de la aplicación.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
