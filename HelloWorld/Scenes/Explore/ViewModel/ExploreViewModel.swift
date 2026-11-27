//
//  ExploreViewModel.swift
//  HelloWorld
//
//  Estructura, organización y contenido asistidos por IA.
//

import Foundation
import Combine

// MARK: - ExploreViewModel
//
// Estado de la búsqueda de especies en iNaturalist.
// Equivale a ExplorarViewModel del proyecto Android, que en Android solo
// simulaba el resultado; aquí la búsqueda es real.
final class ExploreViewModel {

    // MARK: - State

    enum State: Equatable {
        /// Todavía no se ha buscado nada.
        case idle
        /// Búsqueda en curso.
        case loading
        /// Hay al menos una coincidencia.
        case results
        /// La búsqueda no encontró especies.
        case empty
        /// Ocurrió un error; incluye el mensaje para el usuario.
        case failed(String)
    }

    // MARK: - Published State

    @Published private(set) var state: State = .idle
    /// Especie mostrada en la tarjeta «Resultado».
    @Published private(set) var mainResult: INatTaxon?
    /// Resto de coincidencias, mostradas en «Otras coincidencias».
    @Published private(set) var otherMatches: [INatTaxon] = []

    // MARK: - Properties

    private let repository: any ExploreRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init(repository: any ExploreRepositoryProtocol = ExploreRepository()) {
        self.repository = repository
    }

    // MARK: - Public API

    /// Busca especies por nombre. Una búsqueda nueva cancela la anterior.
    func search(_ query: String) {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            clear()
            return
        }

        searchTask?.cancel()
        state = .loading

        // Las actualizaciones de estado se hacen en el hilo principal.
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let taxa = try await self.repository.searchTaxa(text)
                guard !Task.isCancelled else { return }

                guard let first = taxa.first else {
                    self.mainResult = nil
                    self.otherMatches = []
                    self.state = .empty
                    return
                }

                self.mainResult = first
                self.otherMatches = Array(taxa.dropFirst())
                self.state = .results
                await self.loadDetail(for: first)
            } catch {
                guard !Task.isCancelled else { return }
                self.state = .failed(error.localizedDescription)
            }
        }
    }

    /// Convierte una de las otras coincidencias en el resultado principal.
    func select(_ taxon: INatTaxon) {
        guard let current = mainResult, current.id != taxon.id else { return }

        // El resultado anterior regresa a la lista en el lugar del elegido.
        otherMatches = otherMatches.map { $0.id == taxon.id ? current : $0 }
        mainResult = taxon

        Task { @MainActor [weak self] in
            await self?.loadDetail(for: taxon)
        }
    }

    /// Limpia la búsqueda y vuelve al estado inicial.
    func clear() {
        searchTask?.cancel()
        mainResult = nil
        otherMatches = []
        state = .idle
    }

    // MARK: - Helpers

    /// Completa el resultado principal con familia, género y descripción.
    /// Si falla, se conserva la información básica de la búsqueda.
    @MainActor
    private func loadDetail(for taxon: INatTaxon) async {
        do {
            guard let detail = try await repository.taxonDetail(id: taxon.id),
                  mainResult?.id == detail.id else { return }
            mainResult = detail
        } catch {
            print("⚠️ ExploreViewModel: no se pudo cargar el detalle: \(error)")
        }
    }
}
