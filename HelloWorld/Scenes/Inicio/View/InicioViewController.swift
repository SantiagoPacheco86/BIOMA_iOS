//
//  InicioViewController.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import UIKit
import Combine

// MARK: - InicioViewController
//
// Pestaña Inicio: saludo, banner de bienvenida y detecciones recientes.
// Equivale a InicioFragment del proyecto Android.
final class InicioViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = InicioViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private let greetingLabel = BiomaLabel(style: .title)
    private let bannerView = InicioBannerView()
    private let recentSection = UIStackView()
    private let recentCardsStack = UIStackView()
    private let viewAllButton = UIButton(type: .system)

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

        // Campana decorativa, igual que en Android (aún sin notificaciones).
        let bell = UIImageView(image: UIImage(systemName: "bell.fill"))
        bell.tintColor = BiomaTheme.ink
        bell.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24)
        bell.isAccessibilityElement = true
        bell.accessibilityLabel = "Notificaciones"

        let header = BiomaHeaderView(accessory: bell)
        let subtitle = BiomaLabel("La naturaleza siempre tiene algo nuevo que mostrarte.", style: .body)

        setupRecentSection()

        [header, greetingLabel, subtitle, bannerView, recentSection].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(18, after: header)
        contentStack.setCustomSpacing(6, after: greetingLabel)
        contentStack.setCustomSpacing(22, after: subtitle)
        contentStack.setCustomSpacing(28, after: bannerView)
    }

    /// Sección «Tus detecciones recientes» con desplazamiento horizontal.
    private func setupRecentSection() {
        let title = BiomaLabel("Tus detecciones recientes", style: .headline)

        viewAllButton.setTitle("Ver todas ›", for: .normal)
        viewAllButton.setTitleColor(BiomaTheme.textSecondary, for: .normal)
        viewAllButton.titleLabel?.font = BiomaTheme.font(size: 14, relativeTo: .subheadline)
        viewAllButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleRow = UIStackView(arrangedSubviews: [title, viewAllButton])
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 12

        recentCardsStack.axis = .horizontal
        recentCardsStack.spacing = 14
        recentCardsStack.alignment = .top
        recentCardsStack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.clipsToBounds = false   // Deja ver la sombra de las tarjetas.
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(recentCardsStack)

        NSLayoutConstraint.activate([
            recentCardsStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            recentCardsStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            recentCardsStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            recentCardsStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            // La altura de la fila define la del área desplazable.
            recentCardsStack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])

        recentSection.axis = .vertical
        recentSection.spacing = 14
        recentSection.addArrangedSubview(titleRow)
        recentSection.addArrangedSubview(scroll)
        recentSection.isHidden = true
    }

    // MARK: - Actions

    private func setupActions() {
        bannerView.exploreButton.addTarget(self, action: #selector(exploreTapped), for: .touchUpInside)
        viewAllButton.addTarget(self, action: #selector(viewAllTapped), for: .touchUpInside)
    }

    @objc private func exploreTapped() {
        push(ExploreViewController())
    }

    @objc private func viewAllTapped() {
        push(DetectionHistoryViewController())
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$greeting
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.greetingLabel.text = $0 }
            .store(in: &cancellables)

        viewModel.$recentDetections
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.renderRecentDetections($0) }
            .store(in: &cancellables)
    }

    /// Dibuja las tarjetas recientes; la sección se oculta si no hay ninguna.
    private func renderRecentDetections(_ items: [DetectionItem]) {
        recentSection.isHidden = items.isEmpty
        recentCardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in items {
            let card = DetectionCardView()
            card.configure(
                photo: item.photoData.flatMap(UIImage.init(data:)),
                title: item.detection.scientificName,
                subtitle: item.detection.commonName,
                date: item.detection.formattedDate
            )
            recentCardsStack.addArrangedSubview(card)
        }
    }
}

// MARK: - InicioBannerView
//
// Banner «Descubre el mundo natural a tu alrededor» con la foto de la
// mariposa monarca y el botón «Comenzar a explorar», que abre Explorar.
// Reproduce las medidas del banner de fragment_home.xml en Android:
// 180 puntos de alto, esquinas de 16, márgenes internos de 20 y la foto
// recortada al centro sin capas encima.
private final class InicioBannerView: UIView {

    /// Botón expuesto para que la pantalla defina su acción.
    let exploreButton = BiomaButton("Comenzar a explorar →", style: .outlineLight)

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = BiomaTheme.Layout.cardCornerRadius
        layer.cornerCurve = .continuous
        clipsToBounds = true
        // Verde de respaldo (#3B5240) visible mientras la imagen no se ha dibujado.
        backgroundColor = UIColor(hex: 0x3B5240)

        // Foto recortada al centro (equivalente a scaleType="centerCrop").
        let image = UIImageView(image: UIImage(named: "BiomaBanner"))
        image.contentMode = .scaleAspectFill
        image.isAccessibilityElement = false
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)

        // Los saltos de línea replican la distribución del texto en Android.
        let title = BiomaLabel("Descubre el mundo natural\na tu alrededor", style: .headline)
        title.font = BiomaTheme.font(size: 18, weight: .bold, relativeTo: .headline)
        title.textColor = BiomaTheme.white

        let message = BiomaLabel("Identifica plantas, animales y aprende\nmás sobre la biodiversidad que te rodea.", style: .body)
        message.font = BiomaTheme.font(size: 12, relativeTo: .footnote)
        message.textColor = UIColor(hex: 0xD0DDD2)

        // El botón conserva su ancho natural y el espacio sobrante queda a la derecha.
        exploreButton.setContentHuggingPriority(.required, for: .horizontal)
        let buttonRow = UIStackView(arrangedSubviews: [exploreButton, UIView()])
        buttonRow.axis = .horizontal

        let texts = UIStackView(arrangedSubviews: [title, message, buttonRow])
        texts.axis = .vertical
        texts.spacing = 8
        texts.setCustomSpacing(16, after: message)
        texts.translatesAutoresizingMaskIntoConstraints = false
        addSubview(texts)

        // Altura de diseño de 180 puntos; con tamaños de texto grandes el banner
        // crece lo necesario para que el contenido no se recorte.
        let designHeight = heightAnchor.constraint(equalToConstant: 180)
        designHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            designHeight,

            image.topAnchor.constraint(equalTo: topAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),

            // El texto se alinea arriba con 20 puntos de margen, como en Android.
            texts.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            texts.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            texts.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            texts.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) { fatalError("Use init()") }
}

// MARK: - DetectionCardView
//
// Tarjeta vertical de una detección reciente: foto arriba y textos abajo.
// Equivale a item_detection_card.xml.
private final class DetectionCardView: BiomaCardView {

    private let photoView = UIImageView()
    private let titleLabel = BiomaLabel(style: .cardTitle)
    private let subtitleLabel = BiomaLabel(style: .body)
    private let dateLabel = BiomaLabel(style: .caption)

    init() {
        super.init()

        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.backgroundColor = BiomaTheme.authBackground
        photoView.layer.cornerRadius = BiomaTheme.Layout.cardCornerRadius
        photoView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        photoView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = BiomaTheme.font(size: 15, weight: .semibold, relativeTo: .subheadline)
        titleLabel.numberOfLines = 1
        subtitleLabel.numberOfLines = 1

        let texts = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, dateLabel])
        texts.axis = .vertical
        texts.spacing = 4
        texts.setCustomSpacing(10, after: subtitleLabel)
        texts.isLayoutMarginsRelativeArrangement = true
        texts.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 14, trailing: 14)

        let column = UIStackView(arrangedSubviews: [photoView, texts])
        column.axis = .vertical
        embed(column, insets: .zero)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 172),
            photoView.heightAnchor.constraint(equalToConstant: 140)
        ])
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) { fatalError("Use init()") }

    func configure(photo: UIImage?, title: String, subtitle: String, date: String) {
        photoView.image = photo
        titleLabel.text = title
        subtitleLabel.text = subtitle
        dateLabel.text = date
        accessibilityLabel = "\(title), \(subtitle), \(date)"
    }
}
