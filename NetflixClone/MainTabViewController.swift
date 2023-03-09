//
//  ViewController.swift
//  NetflixClone
//
//  Created by mac on 19/01/23.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        
        let firstViewController = UINavigationController(rootViewController: HomeViewController())
        let secondViewController = UINavigationController(rootViewController: UpcomingViewController())
        let thirdViewController = UINavigationController(rootViewController: SearchViewController())
        let fourthNavigationController = UINavigationController(rootViewController: DownloadsViewController())
        
        firstViewController.tabBarItem.image = UIImage(systemName: "house")
        secondViewController.tabBarItem.image = UIImage(systemName: "play.circle")
        thirdViewController.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        fourthNavigationController.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")
        
        firstViewController.title = "Home"
        secondViewController.title = "Upcoming"
        thirdViewController.title = "Search"
        fourthNavigationController.title = "Downloads"
        
        setViewControllers([firstViewController, secondViewController, thirdViewController, fourthNavigationController], animated: true)
                        
        
    }


}
