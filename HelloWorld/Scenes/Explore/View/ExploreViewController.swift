//
//  ExploreViewController.swift
//  HelloWorld
//

import UIKit
import Combine

// MARK: - ExploreViewController
//
// Explorar: búsqueda de plantas y animales en iNaturalist.
// Se abre desde «Comenzar a explorar» en Inicio.
// Equivale a ExplorarFragment del proyecto Android.
final class ExploreViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = ExploreViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private let searchField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let messageLabel = BiomaLabel(style: .body)
    private let resultTitle = BiomaLabel("Resultado", style: .headline)
    private let resultCard = ExploreResultCard()
    private let otherTitle = BiomaLabel("Otras coincidencias", style: .headline)
    private let otherList = UIStackView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
    }

    // MARK: - UI Setup

    private func setupUI() {
        setupScrollableContent(spacing: 14, topInset: 4)

        let header = BiomaHeaderView(title: "Explorar")
        let title = BiomaLabel("Explora especies", style: .title)
        title.font = BiomaTheme.font(size: 28, weight: .bold, relativeTo: .title1)
        let subtitle = BiomaLabel("Busca una planta o animal registrado en Bioma.", style: .body)

        messageLabel.textAlignment = .center
        activityIndicator.color = BiomaTheme.deepForest
        activityIndicator.hidesWhenStopped = true
        otherList.axis = .vertical
        otherList.spacing = 14

        [header, title, subtitle, makeSearchCard(), activityIndicator, messageLabel,
         resultTitle, resultCard, otherTitle, otherList].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(22, after: header)
        contentStack.setCustomSpacing(4, after: title)
        contentStack.setCustomSpacing(20, after: subtitle)
        contentStack.setCustomSpacing(26, after: resultCard)

        render(state: .idle)
    }

    /// Tarjeta de búsqueda: lupa, campo de texto y botón para borrar.
    private func makeSearchCard() -> UIView {
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = BiomaTheme.ink
        searchButton.accessibilityLabel = "Buscar"

        clearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.tintColor = BiomaTheme.ink
        clearButton.accessibilityLabel = "Borrar búsqueda"
        clearButton.isHidden = true

        searchField.attributedPlaceholder = NSAttributedString(
            string: "Ingrese el nombre a buscar...",
            attributes: [.foregroundColor: BiomaTheme.hint]
        )
        searchField.font = BiomaTheme.font(size: 17)
        searchField.adjustsFontForContentSizeCategory = true
        searchField.textColor = BiomaTheme.ink
        searchField.tintColor = BiomaTheme.forest
        searchField.returnKeyType = .search
        searchField.autocorrectionType = .no
        searchField.delegate = self

        [searchButton, clearButton].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.widthAnchor.constraint(equalToConstant: BiomaTheme.Layout.minimumTouchTarget).isActive = true
        }

        let row = UIStackView(arrangedSubviews: [searchButton, searchField, clearButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 6
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true

        return BiomaCardView(content: row, insets: UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
    }

    // MARK: - Actions

    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }

    @objc private func searchTapped() {
        searchField.resignFirstResponder()
        viewModel.search(searchField.text ?? "")
    }

    @objc private func clearTapped() {
        searchField.text = ""
        clearButton.isHidden = true
        viewModel.clear()
    }

    /// El botón para borrar solo aparece cuando hay texto, igual que en Android.
    @objc private func searchTextChanged() {
        clearButton.isHidden = (searchField.text ?? "").isEmpty
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.render(state: $0) }
            .store(in: &cancellables)

        viewModel.$mainResult
            .receive(on: RunLoop.main)
            .sink { [weak self] taxon in
                guard let taxon else { return }
                self?.resultCard.configure(with: taxon)
            }
            .store(in: &cancellables)

        viewModel.$otherMatches
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.renderOtherMatches($0) }
            .store(in: &cancellables)
    }

    /// Muestra u oculta cada sección según el estado de la búsqueda.
    private func render(state: ExploreViewModel.State) {
        let hasResults = state == .results
        resultTitle.isHidden = !hasResults
        resultCard.isHidden = !hasResults
        otherTitle.isHidden = !hasResults || viewModel.otherMatches.isEmpty
        otherList.isHidden = otherTitle.isHidden

        if state == .loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        switch state {
        case .idle:
            messageLabel.text = "Escribe el nombre común o científico de una especie, por ejemplo «encino» o «Quercus»."
        case .empty:
            messageLabel.text = "No encontramos especies con ese nombre."
        case .failed(let message):
            messageLabel.text = message
        case .loading, .results:
            messageLabel.text = nil
        }
        messageLabel.isHidden = messageLabel.text == nil
    }

    /// Dibuja una fila por coincidencia; al tocarla se vuelve el resultado principal.
    private func renderOtherMatches(_ taxa: [INatTaxon]) {
        otherList.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for taxon in taxa {
            let row = BiomaSpeciesRow()
            row.configure(
                title: taxon.name,
                subtitle: taxon.displayCommonName,
                footer: taxon.kind.label,
                footerIcon: taxon.kind.icon
            )
            row.photoView.setRemoteImage(taxon.defaultPhoto?.squareUrl)
            row.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                self.viewModel.select(taxon)
                // Lleva la vista a la tarjeta principal para ver el nuevo resultado.
                let target = self.resultTitle.convert(self.resultTitle.bounds, to: self.scrollView)
                self.scrollView.scrollRectToVisible(target, animated: true)
            }, for: .touchUpInside)
            otherList.addArrangedSubview(row)
        }

        let hasResults = viewModel.state == .results
        otherTitle.isHidden = !hasResults || taxa.isEmpty
        otherList.isHidden = otherTitle.isHidden
    }
}

// MARK: - UITextFieldDelegate

extension ExploreViewController: UITextFieldDelegate {

    /// La tecla «Buscar» del teclado lanza la búsqueda.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapped()
        return true
    }
}

// MARK: - ExploreResultCard
//
// Tarjeta del resultado principal: foto grande, nombres, tipo de organismo,
// familia, género y descripción. Equivale a cv_resultado en Android.
private final class ExploreResultCard: BiomaCardView {

    private let photoView = BiomaRemoteImageView(cornerRadius: 0)
    private let scientificLabel = BiomaLabel(style: .headline)
    private let commonLabel = BiomaLabel(style: .body)
    private let kindPill = BiomaPill("Planta", icon: "leaf", fontSize: 12, background: BiomaTheme.mint)
    private let familyRow = DetailRow(icon: "tree", title: "Familia")
    private let genusRow = DetailRow(icon: "leaf", title: "Género")
    private let descriptionRow = DetailRow(icon: "text.book.closed", title: "Descripción", stacked: true)
    private let pillRow = UIStackView()

    init() {
        super.init()
        clipsToBounds = false

        photoView.layer.cornerRadius = BiomaTheme.Layout.cardCornerRadius
        photoView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        scientificLabel.font = BiomaTheme.font(size: 20, weight: .bold, relativeTo: .title3)
        commonLabel.font = BiomaTheme.font(size: 16, relativeTo: .body)

        kindPill.setContentHuggingPriority(.required, for: .horizontal)
        pillRow.axis = .horizontal
        pillRow.addArrangedSubview(kindPill)
        pillRow.addArrangedSubview(UIView())

        let details = UIStackView(arrangedSubviews: [
            scientificLabel, commonLabel, pillRow,
            Self.divider(), familyRow, Self.divider(), genusRow, Self.divider(), descriptionRow
        ])
        details.axis = .vertical
        details.spacing = 12
        details.setCustomSpacing(4, after: scientificLabel)
        details.isLayoutMarginsRelativeArrangement = true
        details.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 18, leading: 20, bottom: 20, trailing: 20)

        let column = UIStackView(arrangedSubviews: [photoView, details])
        column.axis = .vertical
        embed(column, insets: .zero)

        photoView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("Use init()") }

    /// Muestra los datos de la especie; los campos sin información se ocultan.
    func configure(with taxon: INatTaxon) {
        photoView.setRemoteImage(taxon.defaultPhoto?.mediumUrl)
        scientificLabel.text = taxon.name
        commonLabel.text = taxon.displayCommonName
        commonLabel.isHidden = taxon.displayCommonName == taxon.name
        kindPill.text = taxon.kind.label
        kindPill.setIcon(taxon.kind.icon)

        familyRow.value = taxon.family
        genusRow.value = taxon.genus
        descriptionRow.value = taxon.plainSummary
    }

    private static func divider() -> UIView {
        let line = UIView()
        line.backgroundColor = BiomaTheme.divider
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}

// MARK: - DetailRow
//
// Fila «icono · título · valor» dentro de la tarjeta de resultado.
// Con `stacked` el valor aparece debajo del título (para textos largos).
private final class DetailRow: UIStackView {

    private let valueLabel = BiomaLabel(style: .body)

    /// Valor mostrado; si es `nil` se muestra un guion.
    var value: String? {
        didSet { valueLabel.text = (value ?? "").isEmpty ? "—" : value }
    }

    init(icon: String, title: String, stacked: Bool = false) {
        super.init(frame: .zero)

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = BiomaTheme.deepForest
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let titleLabel = BiomaLabel(title, style: .cardTitle)
        titleLabel.font = BiomaTheme.font(size: 15, weight: .semibold, relativeTo: .subheadline)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        valueLabel.text = "—"
        valueLabel.textColor = BiomaTheme.ink
        valueLabel.textAlignment = stacked ? .natural : .right

        let titleRow = UIStackView(arrangedSubviews: [iconView, titleLabel])
        titleRow.axis = .horizontal
        titleRow.spacing = 10
        titleRow.alignment = .center

        if stacked {
            axis = .vertical
            spacing = 8
            addArrangedSubview(titleRow)
            addArrangedSubview(valueLabel)
        } else {
            axis = .horizontal
            spacing = 12
            alignment = .center
            addArrangedSubview(titleRow)
            addArrangedSubview(valueLabel)
        }
    }

    required init(coder: NSCoder) { fatalError("Use init(icon:title:stacked:)") }
}
