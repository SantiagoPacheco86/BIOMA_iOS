//
//  HelpViewModel.swift
//  HelloWorld
//

import Foundation

// MARK: - HelpViewModel
//
// Contenido de la pantalla de Ayuda. Es informativa: solo expone la URL del
// video y los consejos. Equivale a HelpViewModel del proyecto Android.
final class HelpViewModel {

    // MARK: - Tip

    struct Tip {
        let icon: String
        let title: String
        let message: String
    }

    // MARK: - Content

    /// Video tutorial. Mismo video provisional que en el proyecto Android;
    /// se reemplazará por el tutorial real de BIOMA.
    let videoURL = URL(string: "https://assets.testfiles.dev/video/sample-3s.mp4")

    let videoTitle = "Cómo identificar especies\ncon Bioma"
    let videoDuration = "2:36"

    let tips: [Tip] = [
        Tip(icon: "sun.max",
            title: "Buena iluminación",
            message: "Evita sombras intensas y ambientes demasiado oscuros."),
        Tip(icon: "viewfinder",
            title: "Enfoca la especie",
            message: "Procura que la planta o animal aparezca claramente en la imagen."),
        Tip(icon: "arrow.left.and.right",
            title: "Mantén una distancia adecuada",
            message: "Evita fotografías demasiado lejanas o demasiado cercanas."),
        Tip(icon: "leaf",
            title: "Evita elementos que obstruyan",
            message: "Mantén la especie lo más visible posible y evita objetos que la cubran.")
    ]
}
