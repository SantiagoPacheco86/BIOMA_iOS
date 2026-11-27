//
//  HelpViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit
import AVKit

// MARK: - HelpViewController
//
// Ayuda: video tutorial y consejos para una mejor detección.
// Se abre desde la pestaña Perfil. Equivale a HelpFragment del proyecto Android.
//
// El video no se reproduce automáticamente: se muestra una miniatura con un
// botón de reproducir y el reproductor se crea solo cuando el usuario lo toca.
final class HelpViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = HelpViewModel()
    private var playerController: AVPlayerViewController?

    // MARK: - UI Components

    private let videoContainer = UIView()
    private let thumbnailOverlay = UIView()
    private let playButton = UIButton(type: .custom)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Al salir se libera el reproductor y vuelve a mostrarse la miniatura.
        stopVideo()
    }

    // MARK: - UI Setup

    private func setupUI() {
        setupScrollableContent(spacing: 14, topInset: 4)

        let header = BiomaHeaderView(title: "Ayuda")
        (header.arrangedSubviews.last as? UILabel)?.textColor = BiomaTheme.deepForest

        let videoTitle = makeGreenTitle("¿Cómo realizar una detección?")
        let videoSubtitle = BiomaLabel("Mira el siguiente video para aprender a identificar especies con Bioma paso a paso.", style: .body)

        setupVideoCard()

        let tipsTitle = makeGreenTitle("Consejos para una mejor detección")
        let tipsSubtitle = BiomaLabel("Sigue estas recomendaciones para obtener resultados más precisos.", style: .body)

        [header, videoTitle, videoSubtitle, videoContainer, tipsTitle, tipsSubtitle].forEach {
            contentStack.addArrangedSubview($0)
        }
        viewModel.tips.forEach {
            contentStack.addArrangedSubview(BiomaInfoCard(icon: $0.icon, title: $0.title, message: $0.message))
        }

        contentStack.setCustomSpacing(22, after: header)
        contentStack.setCustomSpacing(6, after: videoTitle)
        contentStack.setCustomSpacing(20, after: videoSubtitle)
        contentStack.setCustomSpacing(30, after: videoContainer)
        contentStack.setCustomSpacing(6, after: tipsTitle)
        contentStack.setCustomSpacing(20, after: tipsSubtitle)
    }

    /// Títulos de sección en verde, como en el diseño de Android.
    private func makeGreenTitle(_ text: String) -> BiomaLabel {
        let label = BiomaLabel(text, style: .sectionTitle)
        label.font = BiomaTheme.font(size: 24, weight: .bold, relativeTo: .title2)
        label.textColor = BiomaTheme.deepForest
        return label
    }

    /// Tarjeta del video: miniatura gris, botón de reproducir, título y duración.
    private func setupVideoCard() {
        videoContainer.backgroundColor = UIColor(hex: 0xCFCCC4)
        videoContainer.layer.cornerRadius = 20
        videoContainer.layer.cornerCurve = .continuous
        videoContainer.clipsToBounds = true
        videoContainer.translatesAutoresizingMaskIntoConstraints = false

        thumbnailOverlay.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.addSubview(thumbnailOverlay)

        // Botón circular de reproducir.
        playButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        playButton.tintColor = BiomaTheme.white
        playButton.setImage(
            UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)),
            for: .normal
        )
        playButton.layer.cornerRadius = 40
        playButton.accessibilityLabel = "Reproducir video"
        playButton.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = BiomaLabel(viewModel.videoTitle, style: .cardTitle)
        titleLabel.textColor = BiomaTheme.white
        titleLabel.font = BiomaTheme.font(size: 18, weight: .bold, relativeTo: .headline)
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.35
        titleLabel.layer.shadowRadius = 3
        titleLabel.layer.shadowOffset = .zero
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let durationLabel = UILabel()
        durationLabel.text = " \(viewModel.videoDuration) "
        durationLabel.textColor = BiomaTheme.white
        durationLabel.font = BiomaTheme.font(size: 15, weight: .bold, relativeTo: .subheadline)
        durationLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        [playButton, titleLabel, durationLabel].forEach { thumbnailOverlay.addSubview($0) }

        NSLayoutConstraint.activate([
            // Proporción 16:9, como un video.
            videoContainer.heightAnchor.constraint(equalTo: videoContainer.widthAnchor, multiplier: 9.0 / 16.0),

            thumbnailOverlay.topAnchor.constraint(equalTo: videoContainer.topAnchor),
            thumbnailOverlay.bottomAnchor.constraint(equalTo: videoContainer.bottomAnchor),
            thumbnailOverlay.leadingAnchor.constraint(equalTo: videoContainer.leadingAnchor),
            thumbnailOverlay.trailingAnchor.constraint(equalTo: videoContainer.trailingAnchor),

            playButton.centerXAnchor.constraint(equalTo: thumbnailOverlay.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: thumbnailOverlay.centerYAnchor, constant: -10),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailOverlay.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: thumbnailOverlay.bottomAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: durationLabel.leadingAnchor, constant: -12),

            durationLabel.trailingAnchor.constraint(equalTo: thumbnailOverlay.trailingAnchor, constant: -20),
            durationLabel.bottomAnchor.constraint(equalTo: thumbnailOverlay.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Video

    /// Crea el reproductor dentro de la tarjeta y comienza la reproducción.
    @objc private func playTapped() {
        guard let url = viewModel.videoURL else {
            showAlert(title: "Video no disponible", message: "No fue posible cargar el video de ayuda.")
            return
        }

        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player

        // El reproductor se agrega como controlador hijo dentro de la tarjeta.
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: videoContainer.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: videoContainer.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: videoContainer.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: videoContainer.trailingAnchor)
        ])
        controller.didMove(toParent: self)

        thumbnailOverlay.isHidden = true
        playerController = controller
        player.play()
    }

    /// Detiene y retira el reproductor, y vuelve a mostrar la miniatura.
    private func stopVideo() {
        guard let controller = playerController else { return }
        controller.player?.pause()
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        playerController = nil
        thumbnailOverlay.isHidden = false
    }
}
