//
//  ViewController.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var homeView: HomeView = {
        return HomeView()
    }()
    
    // MARK: - Variables
    private var viewModel = HomeViewModel()
    private var dataSource: [Pokemon] {
        viewModel.model.data?.pokemon ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Pokemon Box", comment: "")
        
        self.setupSearchController()
        self.setupView()
        self.fetch(type: .start)
    }
    
    private func setupView() {
        self.view.addSubview(homeView)
        
        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(equalTo: self.view.topAnchor),
            homeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            homeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            homeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.homeView.tableView.delegate = self
        self.homeView.tableView.dataSource = self
    }
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.showsBookmarkButton = true
        self.searchController.searchBar.placeholder = NSLocalizedString("Search Pokemon", comment: "")
        self.searchController.searchBar.setImage(UIImage(systemName: "magnifyingglass"), for: .bookmark, state: .normal)
        self.searchController.searchBar.barStyle = .black
    }
    
    private func fetch(type: HomeViewModel.FetchType) {
        self.homeView.showLoading()
        viewModel.fetch(type: type) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    strongSelf.homeView.tableView.reloadData()
                    
                case .failure(let error):
                    if let homeError = error as? HomeViewModel.HomeError {
                        switch homeError {
                        case .emptyData:
                            if type == .start {
                                strongSelf.viewModel.showGenericErrorAlert(from: strongSelf)
                            }
                        case .invalidURL:
                            strongSelf.viewModel.showGenericErrorAlert(from: strongSelf)
                        case .concurrency:
                            break
                        case .noInternetConnection:
                            strongSelf.viewModel.showNoInternetConnectionAlert(from: strongSelf)
                            
                        }
                        
                    }else {
                        strongSelf.viewModel.showGenericErrorAlert(from: strongSelf)
                    }
                }
                strongSelf.homeView.hideLoading()
            }
        }
    }
    
    private func search(text: String) {
        viewModel.searchPokemon(name: text) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    strongSelf.homeView.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    strongSelf.viewModel.showItemNotFoundAlert(from: strongSelf)
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as! HomeTableViewCell
        let pokemon = self.dataSource[indexPath.row]
        cell.pokemon = pokemon
        cell.accessibilityIdentifier = "Cell_\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = dataSource.count - 1
        if indexPath.row == lastElement {
            self.fetch(type: .more)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Search Controller Functions
extension HomeViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate  {
    
    func updateSearchResults(for searchController: UISearchController) {}
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text,
           !text.isEmpty {
            self.search(text: text)
        }else {
            self.fetch(type: .start)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.fetch(type: .start)
    }
}
