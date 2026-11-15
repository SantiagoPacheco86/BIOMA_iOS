//
//  ImagePickerHelper.swift
//  HelloWorld
//

import UIKit

// MARK: - ImagePickerHelper
//
// Abre la cámara o la galería y entrega la imagen elegida.
// Reúne en un solo lugar el código de UIImagePickerController y sus
// delegados, que necesitan Cámara, Perfil y Mi información.
//
// Uso (la pantalla debe conservar una referencia fuerte al ayudante):
//     private lazy var imagePicker = ImagePickerHelper(presenter: self)
//     imagePicker.pick(from: .camera) { image in ... }
final class ImagePickerHelper: NSObject {

    // MARK: - Properties

    private weak var presenter: UIViewController?
    private var completion: ((UIImage) -> Void)?

    // MARK: - Init

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    // MARK: - Public API

    /// Presenta el selector del sistema para el origen indicado.
    /// - Parameters:
    ///   - source: `.camera` para tomar una foto o `.photoLibrary` para elegir una.
    ///   - allowsEditing: Permite recortar la imagen en formato cuadrado.
    ///   - completion: Recibe la imagen elegida; no se llama si el usuario cancela.
    func pick(
        from source: UIImagePickerController.SourceType,
        allowsEditing: Bool = true,
        completion: @escaping (UIImage) -> Void
    ) {
        guard let presenter else { return }

        // El simulador no tiene cámara: se ofrece la galería como alternativa.
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            let alert = UIAlertController(
                title: "Cámara no disponible",
                message: "Este dispositivo no tiene una cámara disponible. ¿Quieres elegir una foto de la galería?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            if source == .camera {
                alert.addAction(UIAlertAction(title: "Galería", style: .default) { [weak self] _ in
                    self?.pick(from: .photoLibrary, allowsEditing: allowsEditing, completion: completion)
                })
            }
            presenter.present(alert, animated: true)
            return
        }

        self.completion = completion

        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.allowsEditing = allowsEditing
        picker.delegate = self
        presenter.present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
//
// UIImagePickerController hereda de UINavigationController; por ello su
// propiedad `delegate` exige la conformidad con ambos protocolos.
extension ImagePickerHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        // Se prioriza la versión recortada; si no existe, se usa la original.
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            print("⚠️ ImagePickerHelper: no se recibió ninguna imagen")
            return
        }
        completion?(image)
        completion = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completion = nil
    }
}
