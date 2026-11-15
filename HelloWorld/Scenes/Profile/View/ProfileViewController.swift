//
//  ProfileViewController.swift
//  HelloWorld
//
//  Created by Santiago Pacheco Temp on 26/10/26.
//

import UIKit
import Combine

// MARK: - ProfileViewController
//
// Pestaña Perfil: foto de perfil, nombre, botones para tomar o seleccionar
// foto y accesos a «Mi información» y «Ayuda».
// Equivale a ProfileFragment del proyecto Android.
final class ProfileViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    private lazy var imagePicker = ImagePickerHelper(presenter: self)

    // MARK: - UI Components

    private let avatarView = BiomaAvatarView(diameter: 150)
    private let nameLabel = BiomaLabel(style: .title)
    private let takePhotoButton = BiomaButton("Tomar foto", icon: "camera")
    private let selectPhotoButton = BiomaButton("Seleccionar foto", icon: "photo.badge.plus")
    private let myInfoRow = BiomaListRow(icon: "person", title: "Mi información", subtitle: "Nombre de usuario, correo, etc.")
    private let helpRow = BiomaListRow(icon: "doc.text", title: "Ayuda", subtitle: "Tutoriales y soporte")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    // MARK: - UI Setup

    private func setupUI() {
        setupScrollableContent(spacing: 16, topInset: 12)

        let header = BiomaHeaderView(title: "Perfil")

        nameLabel.textAlignment = .center
        nameLabel.textColor = BiomaTheme.deepForest
        nameLabel.font = BiomaTheme.font(size: 30, weight: .bold, relativeTo: .title1)

        let subtitle = BiomaLabel("Explorador de la naturaleza", style: .body)
        subtitle.font = BiomaTheme.font(size: 17, relativeTo: .body)
        subtitle.textAlignment = .center

        // Los dos botones comparten el ancho disponible.
        let photoButtons = UIStackView(arrangedSubviews: [takePhotoButton, selectPhotoButton])
        photoButtons.axis = .horizontal
        photoButtons.spacing = 12
        photoButtons.distribution = .fillEqually
        [takePhotoButton, selectPhotoButton].forEach { $0.layer.cornerRadius = 27 }

        let avatarRow = centered(avatarView)
        let myInfoCard = BiomaCardView(content: myInfoRow)
        let helpCard = BiomaCardView(content: helpRow)
        let versionRow = centered(BiomaPill("Bioma v1.0.0", fontSize: 13))

        [header, avatarRow, nameLabel, subtitle, Self.makeLeafDivider(),
         photoButtons, myInfoCard, helpCard, versionRow].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(28, after: header)
        contentStack.setCustomSpacing(18, after: avatarRow)
        contentStack.setCustomSpacing(4, after: nameLabel)
        contentStack.setCustomSpacing(26, after: photoButtons)
        contentStack.setCustomSpacing(30, after: helpCard)
    }

    /// Adorno «—— 🍃 ——» bajo el subtítulo.
    private static func makeLeafDivider() -> UIView {
        func line() -> UIView {
            let view = UIView()
            view.backgroundColor = BiomaTheme.ink
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 28),
                view.heightAnchor.constraint(equalToConstant: 1.5)
            ])
            return view
        }

        let leaf = UIImageView(image: UIImage(systemName: "leaf"))
        leaf.tintColor = BiomaTheme.ink
        leaf.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13)

        let stack = UIStackView(arrangedSubviews: [line(), leaf, line()])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.isAccessibilityElement = false

        let wrapper = UIView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: wrapper.topAnchor),
            stack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            stack.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor)
        ])
        return wrapper
    }

    // MARK: - Actions

    private func setupActions() {
        takePhotoButton.addTarget(self, action: #selector(takePhotoTapped), for: .touchUpInside)
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoTapped), for: .touchUpInside)
        // En Android, el botón de cámara sobre la foto abre la galería.
        avatarView.badgeButton.addTarget(self, action: #selector(selectPhotoTapped), for: .touchUpInside)
        myInfoRow.addTarget(self, action: #selector(myInfoTapped), for: .touchUpInside)
        helpRow.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
    }

    @objc private func takePhotoTapped() {
        imagePicker.pick(from: .camera) { [weak self] in self?.updatePhoto($0) }
    }

    @objc private func selectPhotoTapped() {
        imagePicker.pick(from: .photoLibrary) { [weak self] in self?.updatePhoto($0) }
    }

    @objc private func myInfoTapped() {
        push(InformationViewController())
    }

    @objc private func helpTapped() {
        push(HelpViewController())
    }

    /// Guarda la foto elegida como foto de perfil.
    private func updatePhoto(_ image: UIImage) {
        // JPEG con 80 % de calidad: buen balance entre nitidez y tamaño de archivo.
        guard let data = image.jpegData(compressionQuality: 0.8), viewModel.savePhoto(data) else {
            showAlert(title: "No se pudo guardar", message: "La foto no se pudo guardar en el dispositivo.")
            return
        }
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$name
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.nameLabel.text = $0 }
            .store(in: &cancellables)

        viewModel.$photoData
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.avatarView.setImage(data.flatMap(UIImage.init(data:)))
            }
            .store(in: &cancellables)
    }
}
