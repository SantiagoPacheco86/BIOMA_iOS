//
//  DetectionHistoryViewController.swift
//  HelloWorld
//

import UIKit
import Combine

// MARK: - DetectionHistoryViewController
//
// Historial: lista de todas las detecciones del usuario con su contador.
// Se abre desde «Ver todas» (Inicio) o «Historial» (Cámara).
// Equivale a DetectionFragment del proyecto Android.
final class DetectionHistoryViewController: BiomaViewController {

    // MARK: - Properties

    private let viewModel = DetectionHistoryViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private let counterPill = BiomaPill("0 de 50 detecciones", fontSize: 12)
    private let emptyLabel = BiomaLabel("Aún no tienes detecciones", style: .body)
    private let listStack = UIStackView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    // MARK: - UI Setup

    private func setupUI() {
        setupScrollableContent(spacing: 14, topInset: 8)

        let header = BiomaHeaderView(title: "Historial")
        let title = BiomaLabel("Tus detecciones", style: .title)
        title.font = BiomaTheme.font(size: 26, weight: .bold, relativeTo: .title1)
        let subtitle = BiomaLabel("Consulta las especies que has identificado.", style: .body)

        let counterRow = UIStackView(arrangedSubviews: [counterPill, UIView()])
        counterRow.axis = .horizontal
        counterPill.setContentHuggingPriority(.required, for: .horizontal)

        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        listStack.axis = .vertical
        listStack.spacing = 14

        [header, title, subtitle, counterRow, emptyLabel, listStack].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(22, after: header)
        contentStack.setCustomSpacing(4, after: title)
        contentStack.setCustomSpacing(18, after: counterRow)
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$detections
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.renderList($0) }
            .store(in: &cancellables)

        viewModel.$counterText
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.counterPill.text = $0 }
            .store(in: &cancellables)
    }

    /// Dibuja una fila por detección; muestra el mensaje vacío si no hay ninguna.
    private func renderList(_ items: [DetectionItem]) {
        emptyLabel.isHidden = !items.isEmpty
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in items {
            let row = BiomaSpeciesRow()
            row.configure(
                title: item.detection.scientificName,
                subtitle: item.detection.commonName,
                footer: item.detection.formattedDate
            )
            row.photoView.setLocalImage(item.photoData.flatMap(UIImage.init(data:)))
            listStack.addArrangedSubview(row)
        }
    }
}
