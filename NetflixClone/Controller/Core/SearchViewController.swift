//
//  SearchViewController.swift
//  NetflixClone
//
//  Created by mac on 19/01/23.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let discoverTableView: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        
        controller.searchBar.placeholder = "Search for a movie or a TV show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    private var titles: [Title] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(discoverTableView)
        discoverTableView.delegate = self
        discoverTableView.dataSource = self
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        
        fetchDiscoverMovies()
        
        searchController.searchResultsUpdater = self
    }
    
    private func fetchDiscoverMovies() {
        APICaller.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let discoveredMovies):
                self?.titles = discoveredMovies
                DispatchQueue.main.async {
                    self?.discoverTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTableView.frame = view.bounds
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titles[indexPath.row]
        
        cell.configure(
            with: TitleViewModel(
                titleName: title.original_title ?? "",
                posterURL: title.poster_path ?? ""
            )
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTitle = self.titles[indexPath.row]
        
        APICaller.shared.getMovie(
            with: selectedTitle.original_title ?? "" + " trailer") { [weak self] result in
                switch result {
                case .success(let videoElement):
                    DispatchQueue.main.async {
                        let viewController = TitlePreviewViewController()
                        viewController.configure(
                            with: TitlePreviewViewModel(
                                title: selectedTitle.original_title ?? "",
                                youtubeVideo: videoElement,
                                titleOverview: selectedTitle.overview ?? ""
                            )
                        )
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
}

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        
        resultsController.delegate = self
        
        APICaller.shared.search(with: query) { result in
                    switch result {
                    case .success(let titles):
                resultsController.titles = titles
                DispatchQueue.main.async {
                    resultsController.searchBarResultsCollectionView.reloadData()
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async {
            let viewController = TitlePreviewViewController()
            viewController.configure(with: viewModel)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

