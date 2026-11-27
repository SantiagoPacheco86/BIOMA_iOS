//
//  BiomaRemoteImageView.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit

// MARK: - ImageLoader
//
// Descarga imágenes desde internet y las conserva en una caché en memoria
// para no volver a descargarlas al desplazarse por una lista.
final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let session = URLSession(configuration: .default)

    private init() {
        cache.countLimit = 150
    }

    /// Devuelve la imagen de la URL, desde la caché si ya se descargó antes.
    func image(from url: URL) async throws -> UIImage {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }

        let (data, _) = try await session.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}

// MARK: - BiomaRemoteImageView
//
// UIImageView que puede mostrar una imagen local o una remota (URL).
// Si se pide una nueva imagen antes de que termine la anterior, la descarga
// previa se cancela para evitar que una celda muestre una foto equivocada.
final class BiomaRemoteImageView: UIImageView {

    // MARK: - Properties

    private var loadTask: Task<Void, Never>?

    // MARK: - Init

    init(cornerRadius: CGFloat = 12) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BiomaTheme.authBackground
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        tintColor = BiomaTheme.border
    }

    required init?(coder: NSCoder) { fatalError("Use init(cornerRadius:)") }

    // MARK: - Public API

    /// Muestra una imagen local; `nil` deja el fondo vacío.
    func setLocalImage(_ image: UIImage?) {
        loadTask?.cancel()
        self.image = image
        contentMode = .scaleAspectFill
    }

    /// Descarga y muestra la imagen de la URL indicada.
    /// - Parameter urlString: Dirección de la imagen; `nil` o vacía muestra un marcador.
    func setRemoteImage(_ urlString: String?) {
        loadTask?.cancel()
        showPlaceholder()

        guard let urlString, let url = URL(string: urlString) else { return }

        // Las vistas de UIKit viven en el hilo principal; la tarea hereda ese contexto.
        loadTask = Task { @MainActor [weak self] in
            do {
                let downloaded = try await ImageLoader.shared.image(from: url)
                guard !Task.isCancelled else { return }
                self?.image = downloaded
                self?.contentMode = .scaleAspectFill
            } catch {
                // Si falla la descarga se conserva el marcador.
            }
        }
    }

    // MARK: - Helpers

    private func showPlaceholder() {
        image = UIImage(systemName: "photo")
        contentMode = .center
    }
}
