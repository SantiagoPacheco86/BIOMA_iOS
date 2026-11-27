//
//  CameraViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit
import Combine

// MARK: - CameraViewController
//
// Pestaña Cámara: botón de obturador que toma una foto, la guarda como
// detección y, si es posible, identifica la especie con iNaturalist.
// Equivale a CameraFragment del proyecto Android.
final class CameraViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = CameraViewModel()
    private var cancellables = Set<AnyCancellable>()
    private lazy var imagePicker = ImagePickerHelper(presenter: self)

    override var screenBackgroundColor: UIColor { BiomaTheme.authBackground }

    // MARK: - UI Components

    private let historyButton = BiomaButton("Historial", style: .link)
    private let hintLabel = BiomaLabel(
        "Toca el botón para tomar una foto\nde la planta o animal que quieres identificar",
        style: .body
    )
    private let photoView = UIImageView()
    private let captureButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let identifyingLabel = BiomaLabel("Identificando especie…", style: .caption)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
    }

    // MARK: - UI Setup

    private let header = BiomaHeaderView()
    private lazy var identifyingRow = UIStackView(arrangedSubviews: [activityIndicator, identifyingLabel])

    private func setupUI() {
        header.addArrangedSubview(historyButton)

        hintLabel.font = BiomaTheme.font(size: 16, relativeTo: .body)
        hintLabel.textAlignment = .center

        // Foto capturada; oculta hasta que exista una.
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.layer.cornerRadius = 20
        photoView.layer.cornerCurve = .continuous
        photoView.isHidden = true
        photoView.isAccessibilityElement = true
        photoView.accessibilityLabel = "Última foto tomada"

        // Botón de obturador: icono de diafragma en verde BIOMA.
        captureButton.setImage(
            UIImage(
                systemName: "camera.aperture",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 72, weight: .regular)
            ),
            for: .normal
        )
        captureButton.tintColor = BiomaTheme.deepForest
        captureButton.accessibilityLabel = "Tomar foto"

        identifyingRow.axis = .horizontal
        identifyingRow.spacing = 8
        identifyingRow.alignment = .center
        identifyingRow.isHidden = true
        activityIndicator.color = BiomaTheme.deepForest

        [header, hintLabel, photoView, identifyingRow, captureButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        let margin = BiomaTheme.Layout.horizontalMargin
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            header.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),

            // Botón de obturador centrado en la parte inferior.
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -28),
            captureButton.widthAnchor.constraint(equalToConstant: 96),
            captureButton.heightAnchor.constraint(equalToConstant: 96),

            identifyingRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            identifyingRow.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -12),

            // La foto ocupa el área entre el encabezado y el indicador.
            photoView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 24),
            photoView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            photoView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            photoView.bottomAnchor.constraint(equalTo: identifyingRow.topAnchor, constant: -16),

            // El texto de ayuda queda centrado en esa misma área.
            hintLabel.centerYAnchor.constraint(equalTo: photoView.centerYAnchor),
            hintLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            hintLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin)
        ])
    }

    // MARK: - Actions

    private func setupActions() {
        captureButton.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
    }

    @objc private func captureTapped() {
        // Sin recorte: la foto completa se conserva para la identificación.
        imagePicker.pick(from: .camera, allowsEditing: false) { [weak self] image in
            self?.handleCapturedImage(image)
        }
    }

    @objc private func historyTapped() {
        push(DetectionHistoryViewController())
    }

    /// Muestra la foto, la guarda como detección y lanza la identificación.
    private func handleCapturedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let detection = viewModel.savePhoto(data) else {
            showAlert(title: "No se pudo guardar", message: "La foto no se pudo guardar en el dispositivo.")
            return
        }

        photoView.image = image
        photoView.isHidden = false
        hintLabel.isHidden = true
        showToast("Detección guardada")

        // Sin token de iNaturalist la detección queda pendiente, igual que en Android.
        guard viewModel.canIdentify else { return }

        Task { [weak self] in
            guard let self else { return }
            let message = await self.viewModel.identify(detection, photoData: data)
            self.showToast(message)
        }
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$isIdentifying
            .receive(on: RunLoop.main)
            .sink { [weak self] identifying in
                self?.identifyingRow.isHidden = !identifying
                self?.captureButton.isEnabled = !identifying
                if identifying {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
}
