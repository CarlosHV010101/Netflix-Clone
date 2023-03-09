//
//  UpcomingViewController.swift
//  NetflixClone
//
//  Created by mac on 19/01/23.
//

import UIKit

class UpcomingViewController: UIViewController {
    
    private var upcomingTitles: [Title] = []
    
    private let upcomingTable: UITableView = {
       let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(upcomingTable)
        upcomingTable.delegate = self
        upcomingTable.dataSource = self
        
        self.fetchUpcoming()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds
    }
    
    func update(with titles: [Title]) {
        self.upcomingTitles = titles
        DispatchQueue.main.async {
            self.upcomingTable.reloadData()
        }
    }
    
    private func fetchUpcoming() {
        APICaller.shared.getUpcomingMovies { [weak self] result in
            switch result {
            case .success(let upcomingTitles):
                self?.update(with: upcomingTitles)
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.upcomingTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = TitleViewModel(titleName: upcomingTitles[indexPath.row].original_title ?? "Unknown", posterURL: upcomingTitles[indexPath.row].poster_path ?? "")
        
        cell.configure(with: title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTitle = self.upcomingTitles[indexPath.row]
        
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
