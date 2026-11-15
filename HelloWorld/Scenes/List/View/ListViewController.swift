//
//  ListViewController.swift
//  HelloWorldJdJVL
//
//  Created by José De Jesús Vega López on 21/04/26.
//

// ⚠️ TEMPORAL: ejemplo de clase con PokeAPI.
// Este archivo se adaptará a la API definitiva de BIOMA.
//
// Diferencia respecto al ejemplo de clase: la tabla se crea por código
// (`listTable`) en lugar de usar un @IBOutlet, porque List.storyboard no
// contiene un UITableView y la conexión provocaría un cierre de la app.

import UIKit

class ListViewController: UIViewController {
    
    // MARK: - PUBLIC PROPERTIES
    let viewModel = ListViewModel()
    
    // MARK: - PRIVATE PROPERTIES
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Ui Components
    
    /// Tabla creada por código; sustituye al @IBOutlet del ejemplo de clase.
    private let listTable = UITableView()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "Oops...\nSorry, we couldn't find any pokemon."
        label.textAlignment = .center
        return label
    }()
        
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        configureComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getMovieList()
    }
    
    /// Agrega la tabla a la vista y la ajusta a toda la pantalla.
    private func setupTable() {
        listTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listTable)
        
        NSLayoutConstraint.activate([
            listTable.topAnchor.constraint(equalTo: view.topAnchor),
            listTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureComponents() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        listTable.addSubview(refreshControl)
        listTable.delegate = self
        listTable.dataSource = self
        listTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    @objc private func refresh(_ sender: AnyObject) {
        //getMovieList()
        
        // only to see empty state
        viewModel.pokemonList = []
        reloadData()
        
        refreshControl.endRefreshing()
    }
    
    private func getMovieList() {
        Task {
            do {
                try await viewModel.getPokemonList()
                reloadData()
            }
            catch {
                showAlert(title: "Oops...", message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    private func reloadData() {
        listTable.reloadData()
        if !viewModel.hasContent {
            listTable.backgroundView = emptyLabel
            listTable.separatorStyle = .none
        }
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // CELL TAPPED
        print("cell tapped")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // numero de elementos
        return viewModel.pokemonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // obtenemos el data por posición
        let data = viewModel.pokemonList[indexPath.row]
        
        // Crea una celda default
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Configuración default
        var content = cell.defaultContentConfiguration()
        
        // Configure content
        content.text = data.name
        content.secondaryText = data.url
        content.image = UIImage(systemName: "cat.fill")
        
        // Assign configuration back to the cell
        cell.contentConfiguration = content
        
        return cell
    }
    
}
