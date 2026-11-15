//
//  ProfileViewController.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 26/10/26.
//

import UIKit
import AVKit
import AVFoundation

// MARK: - ProfileViewController
//
// Pantalla de perfil del usuario.
//
// Responsabilidades:
//   • Mostrar y actualizar la foto de perfil mediante la cámara o la galería.
//   • Reproducir un video de ayuda y un audio de muestra desde la barra de navegación.
//
// La interfaz se construye de forma programática con los componentes del
// DesignSystem de BIOMA (BiomaButton, BiomaLabel y BiomaTheme).
final class ProfileViewController: UIViewController {

    // MARK: - Constants

    /// Direcciones de los recursos multimedia de demostración.
    private enum MediaURL {
        static let helpVideo = "https://cdn.lephenix.fr/wp-content/uploads/2022/10/07104840/big_buck_bunny_720p_1mb.mp4"
        static let sampleAudio = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    }

    /// Medidas propias de esta pantalla.
    private enum Metrics {
        static let photoSize: CGFloat = 200
        static let photoCornerRadius: CGFloat = 16
        static let placeholderIconSize: CGFloat = 56
        static let topMargin: CGFloat = 32
    }

    // MARK: - Properties

    /// Reproductor de audio activo. Es `nil` cuando no hay audio en reproducción.
    private var audioPlayer: AVPlayer?
    
    /// Almacenamiento persistente de la foto de perfil.
    private let photoStore = ProfilePhotoStore()

    /// Usuario de la sesión actual; determina qué foto se carga y se guarda.
    private var currentUsername: String? {
        UserStore.shared.lastLoggedInUsername
    }

    // MARK: - UI Components

    /// Contenedor de la foto de perfil.
    private let photoImageView = UIImageView()

    /// Botón primario que abre el menú de selección de imagen.
    private let addPhotoButton = BiomaButton("Agregar foto")

    /// Texto descriptivo ubicado sobre la foto de perfil.
    private let subtitleLabel = BiomaLabel(
        "Agrega una foto para tu perfil de explorador.",
        style: .body
    )

    /// Pila vertical que organiza el texto, la foto y el botón.
    private let contentStack = UIStackView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupNavigationItems()
        loadSavedPhoto()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // El audio se detiene cuando la pantalla deja de estar visible para
        // evitar que continúe reproduciéndose en segundo plano.
        stopAudio()
    }

    // MARK: - UI Setup

    /// Configura la jerarquía de vistas y la apariencia de los componentes.
    private func setupUI() {
        view.backgroundColor = BiomaTheme.background

        // Pila vertical centrada horizontalmente.
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = BiomaTheme.Layout.spacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)

        // Superficie blanca con esquinas redondeadas y borde discreto.
        photoImageView.backgroundColor = BiomaTheme.white
        photoImageView.layer.cornerRadius = Metrics.photoCornerRadius
        photoImageView.layer.cornerCurve = .continuous
        photoImageView.layer.borderWidth = 1
        photoImageView.layer.borderColor = BiomaTheme.hint.withAlphaComponent(0.3).cgColor
        // Recorta la imagen para respetar las esquinas redondeadas.
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.isAccessibilityElement = true
        showPlaceholder()

        subtitleLabel.textAlignment = .center

        [subtitleLabel, photoImageView, addPhotoButton].forEach {
            contentStack.addArrangedSubview($0)
        }
        // Separación adicional entre la foto y el botón.
        contentStack.setCustomSpacing(BiomaTheme.Layout.sectionSpacing, after: photoImageView)
    }

    /// Configura los botones de la barra de navegación para el contenido multimedia.
    private func setupNavigationItems() {
        let helpButton = UIBarButtonItem(
            title: "Ayuda",
            style: .plain,
            target: self,
            action: #selector(didTapHelp)
        )
        let playButton = UIBarButtonItem(
            barButtonSystemItem: .play,
            target: self,
            action: #selector(didTapPlayAudio)
        )
        let pauseButton = UIBarButtonItem(
            barButtonSystemItem: .pause,
            target: self,
            action: #selector(didTapStopAudio)
        )

        // Etiquetas para VoiceOver, ya que los iconos no incluyen texto.
        playButton.accessibilityLabel = "Reproducir audio"
        pauseButton.accessibilityLabel = "Detener audio"

        navigationItem.setRightBarButtonItems([helpButton], animated: false)
        navigationItem.setLeftBarButtonItems([pauseButton, playButton], animated: false)
    }

    /// Muestra un icono de marcador mientras no exista una foto de perfil.
    private func showPlaceholder() {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: Metrics.placeholderIconSize,
            weight: .light
        )
        photoImageView.image = UIImage(systemName: "person.crop.square", withConfiguration: configuration)
        photoImageView.tintColor = BiomaTheme.hint
        // El icono se muestra centrado y con su tamaño original.
        photoImageView.contentMode = .center
        photoImageView.accessibilityLabel = "Sin foto de perfil"
    }

    /// Muestra la foto seleccionada y actualiza el texto del botón.
    /// - Parameter photo: Imagen obtenida de la cámara o de la galería.
    private func showPhoto(_ photo: UIImage) {
        photoImageView.image = photo
        // Ocupa todo el contenedor sin deformar la imagen.
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.accessibilityLabel = "Foto de perfil"
        addPhotoButton.setTitle("Cambiar foto", for: .normal)
    }

    // MARK: - Constraints

    /// Define la posición y el tamaño de los componentes mediante Auto Layout.
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Pila anclada al área segura superior con los márgenes de BIOMA.
            contentStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.topMargin
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: BiomaTheme.Layout.horizontalMargin
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -BiomaTheme.Layout.horizontalMargin
            ),

            // Contenedor cuadrado para la foto.
            photoImageView.widthAnchor.constraint(equalToConstant: Metrics.photoSize),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor),

            // El botón comparte el ancho de la foto.
            addPhotoButton.widthAnchor.constraint(equalTo: photoImageView.widthAnchor)
        ])
    }

    // MARK: - Actions

    /// Asocia los eventos de los controles con sus métodos de respuesta.
    private func setupActions() {
        addPhotoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)
    }

    /// Presenta un menú para elegir el origen de la imagen.
    @objc private func photoTapped() {
        // En iPhone se presenta desde la parte inferior; en iOS 26 el sistema
        // puede mostrarlo con apariencia de alerta.
        let alert = UIAlertController(
            title: "Selecciona una imagen",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Cámara", style: .default) { [weak self] _ in
            self?.presentImagePicker(source: .camera)
        })
        alert.addAction(UIAlertAction(title: "Galería", style: .default) { [weak self] _ in
            self?.presentImagePicker(source: .photoLibrary)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        // En iPad, un actionSheet requiere un punto de anclaje para presentarse.
        alert.popoverPresentationController?.sourceView = addPhotoButton
        alert.popoverPresentationController?.sourceRect = addPhotoButton.bounds

        present(alert, animated: true)
    }

    /// Presenta el selector de imágenes del sistema para el origen indicado.
    /// - Parameter source: `.camera` para tomar una foto o `.photoLibrary` para elegir una existente.
    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        // Verifica que el origen esté disponible; el simulador no dispone de cámara.
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            let message = source == .camera
                ? "La cámara no está disponible en este dispositivo. En el simulador utiliza la Galería."
                : "No es posible acceder a la galería."
            showAlert(title: "No disponible", message: message)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = source
        // Permite recortar la imagen en formato cuadrado antes de confirmarla.
        picker.allowsEditing = true
        // El controlador recibe la imagen seleccionada o la cancelación.
        picker.delegate = self
        present(picker, animated: true)
    }

    /// Reproduce el video de ayuda en el reproductor del sistema.
    @objc private func didTapHelp() {
        guard let url = URL(string: MediaURL.helpVideo) else {
            print("⚠️ Profile: URL de video no válida")
            return
        }

        // Detiene el audio para evitar reproducir dos fuentes simultáneamente.
        stopAudio()

        let videoPlayer = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = videoPlayer

        // `present` muestra el reproductor de forma modal sobre la pantalla actual;
        // se cierra con `dismiss`, a diferencia de `push`, que lo agregaría a la
        // pila de navegación y se cerraría con `pop`.
        present(playerViewController, animated: true) {
            videoPlayer.play()
        }
    }

    /// Inicia la reproducción del audio de muestra.
    @objc private func didTapPlayAudio() {
        guard let url = URL(string: MediaURL.sampleAudio) else {
            print("⚠️ Profile: URL de audio no válida")
            return
        }

        do {
            // Configura la sesión de audio para reproducción, incluso con el
            // interruptor de silencio activado.
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("⚠️ Profile: no se pudo configurar la sesión de audio: \(error.localizedDescription)")
            return
        }

        // Sustituye cualquier reproducción previa por una nueva.
        stopAudio()
        let player = AVPlayer(url: url)
        audioPlayer = player
        player.play()
    }

    /// Detiene la reproducción del audio de muestra.
    @objc private func didTapStopAudio() {
        stopAudio()
    }

    // MARK: - Helpers

    /// Muestra la foto guardada del usuario actual, si existe.
    private func loadSavedPhoto() {
        guard let username = currentUsername,
              let data = photoStore.load(for: username),
              let photo = UIImage(data: data) else {
            return
        }
        showPhoto(photo)
    }

    /// Guarda la foto seleccionada para el usuario actual.
    private func savePhoto(_ photo: UIImage) {
        guard let username = currentUsername else { return }

        // JPEG con 80 % de calidad: buen balance entre nitidez y tamaño de archivo.
        guard let data = photo.jpegData(compressionQuality: 0.8),
              photoStore.save(data, for: username) else {
            showAlert(
                title: "No se pudo guardar",
                message: "La foto se muestra, pero no se guardó en el dispositivo."
            )
            return
        }
    }
    
    /// Pausa y libera el reproductor de audio, si existe.
    private func stopAudio() {
        audioPlayer?.pause()
        audioPlayer = nil
    }

    /// Presenta una alerta informativa con un único botón de confirmación.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
//
// `UIImagePickerController` hereda de `UINavigationController`; por ello su
// propiedad `delegate` exige la conformidad con ambos protocolos, aunque solo
// se implementan los métodos de `UIImagePickerControllerDelegate`.
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// Recibe la imagen tomada o seleccionada y la muestra en el perfil.
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        // Se prioriza la versión recortada; si no existe, se utiliza la original.
        guard let photo = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            print("⚠️ Profile: no se recibió ninguna imagen")
            return
        }
        showPhoto(photo)
        savePhoto(photo)
    }

    /// Cierra el selector cuando el usuario cancela la operación.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
