//
//  BaseRouter.swift
//  GBMap
//
//  Created by Павел Заруцков on 18.06.2022.
//

import UIKit

protocol ViewControllerRouterInput {
    func navigateToViewController(value: Int)
}

final class ViewControllerRouter: ViewControllerRouterInput {

    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    // MARK: - ViewControllerRouterInput

    func navigateToViewController(value: Int) {
        let pushedViewController = MapViewController()
        pushedViewController.configure(viewModel: MapViewModel(value: value))
        viewController?.navigationController?.pushViewController(pushedViewController, animated: true)
    }
}
