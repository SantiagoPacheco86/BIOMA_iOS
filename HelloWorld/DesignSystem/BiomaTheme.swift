import UIKit

// MARK: - BiomaTheme
//
// Fuente única de verdad de la identidad visual de BIOMA.
// Los componentes (BiomaButton, BiomaField, BiomaLabel) y las pantallas
// leen de aquí colores, medidas y tipografía, de modo que un cambio de
// identidad se hace en un solo lugar y nunca repitiendo valores RGB.
enum BiomaTheme {

    // MARK: - Colors

    /// #F3EFE6 · Fondo hueso predominante de las pantallas.
    static let background = UIColor(red: 243/255, green: 239/255, blue: 230/255, alpha: 1)
    /// #465940 · Color principal de la marca: botones primarios y acentos.
    static let forest = UIColor(red: 70/255, green: 89/255, blue: 64/255, alpha: 1)
    /// #596A50 · Subtítulos, descripciones y elementos secundarios.
    static let olive = UIColor(red: 89/255, green: 106/255, blue: 80/255, alpha: 1)
    /// #30352F · Sustituye al negro puro en títulos y texto principal.
    static let ink = UIColor(red: 48/255, green: 53/255, blue: 47/255, alpha: 1)
    /// #8E8A82 · Placeholders y texto auxiliar.
    static let hint = UIColor(red: 142/255, green: 138/255, blue: 130/255, alpha: 1)
    /// #FFFFFF · Superficie de campos y texto sobre botones.
    static let white = UIColor.white
    /// Errores de validación. Nunca debe usarse como color decorativo.
    static let error = UIColor.systemRed

    // MARK: - Layout

    /// Medidas de referencia del documento de contexto (sección 4.2).
    enum Layout {
        static let fieldHeight: CGFloat = 50
        static let buttonHeight: CGFloat = 52
        static let fieldCornerRadius: CGFloat = 12
        static let buttonCornerRadius: CGFloat = 14
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
}
