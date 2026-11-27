//
//  BiomaTheme.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - BiomaTheme
//
// Fuente única de verdad de la identidad visual de BIOMA.
// Los componentes del DesignSystem y las pantallas leen de aquí colores,
// medidas y tipografía, de modo que un cambio de identidad se realiza en un
// solo lugar y nunca repitiendo valores RGB.
//
// La paleta replica la del proyecto Android de BIOMA.
enum BiomaTheme {

    // MARK: - Colors

    /// #F3F1EA · Fondo de las pantallas internas (Inicio, Perfil, Explorar…).
    static let background = UIColor(hex: 0xF3F1EA)
    /// #F8F6EE · Fondo de las pantallas de bienvenida (Splash, Login, Registro, Cámara).
    static let authBackground = UIColor(hex: 0xF8F6EE)
    /// #FAF8F5 · Superficie de tarjetas y campos.
    static let surface = UIColor(hex: 0xFAF8F5)

    /// #465940 · Color principal de la marca: botones primarios y acentos.
    static let forest = UIColor(hex: 0x465940)
    /// #243D2D · Verde profundo para títulos destacados y el nombre BIOMA.
    static let deepForest = UIColor(hex: 0x243D2D)
    /// #596A50 · Subtítulos, descripciones y elementos secundarios.
    static let olive = UIColor(hex: 0x596A50)
    /// #A99D8D · Tono arena del logotipo (la «O» de BIOMA).
    static let taupe = UIColor(hex: 0xA99D8D)
    /// #EAF0EC · Fondo de los círculos de iconos.
    static let mint = UIColor(hex: 0xEAF0EC)

    /// #30352F · Sustituye al negro puro en títulos y texto principal.
    static let ink = UIColor(hex: 0x30352F)
    /// #666666 · Texto secundario de tarjetas y descripciones.
    static let textSecondary = UIColor(hex: 0x666666)
    /// #8E8A82 · Placeholders y texto auxiliar.
    static let hint = UIColor(hex: 0x8E8A82)

    /// #EAE6DC · Separadores entre filas.
    static let divider = UIColor(hex: 0xEAE6DC)
    /// #C5BFB3 · Bordes discretos (por ejemplo, el aro de la foto de perfil).
    static let border = UIColor(hex: 0xC5BFB3)
    /// #E6E3D9 · Fondo de etiquetas tipo píldora.
    static let pill = UIColor(hex: 0xE6E3D9)

    /// #FFFFFF · Texto sobre botones y superficies que necesitan contraste.
    static let white = UIColor.white
    /// Errores de validación. Nunca debe usarse como color decorativo.
    static let error = UIColor.systemRed

    // MARK: - Layout

    /// Medidas compartidas por los componentes y las pantallas.
    enum Layout {
        static let fieldHeight: CGFloat = 56
        static let buttonHeight: CGFloat = 54
        static let fieldCornerRadius: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let cardCornerRadius: CGFloat = 16
        static let horizontalMargin: CGFloat = 24
        static let spacing: CGFloat = 14
        static let fieldErrorSpacing: CGFloat = 5
        static let sectionSpacing: CGFloat = 26
        /// Área táctil mínima recomendada por Apple para controles interactivos.
        static let minimumTouchTarget: CGFloat = 44
        /// Opacidad de un control deshabilitado o presionado.
        static let disabledAlpha: CGFloat = 0.5
        static let pressedAlpha: CGFloat = 0.8
    }

    // MARK: - Typography

    /// Devuelve una fuente del sistema que respeta Dynamic Type.
    ///
    /// `size` es el tamaño de diseño (el que se ve con el tamaño de texto
    /// por defecto). `UIFontMetrics` lo escala proporcionalmente cuando el
    /// usuario aumenta o reduce el texto en Ajustes > Accesibilidad.
    /// Para que el escalado sea en vivo, el componente debe activar
    /// `adjustsFontForContentSizeCategory`.
    static func font(
        size: CGFloat,
        weight: UIFont.Weight = .regular,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }

    // MARK: - Shadow

    /// Sombra suave usada por tarjetas y campos, equivalente a la elevación de Android.
    static func applyCardShadow(to layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}

// MARK: - UIColor + Hex

extension UIColor {

    /// Crea un color a partir de un valor hexadecimal, por ejemplo `0x465940`.
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
