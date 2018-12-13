//
//  ImagesViewController.swift
//  ImageSearch
//
//  Created by User on 12/04/2018.
//  Copyright © 2018 MPTechnologies. All rights reserved.
//
import UIKit
import SwiftyJSON

class ImagesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstrait: NSLayoutConstraint!

    var presenter: ImagesPresenter!

    // MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search your dreams"
        setup()

        var names:[String] = []
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        showActivityHUD()
        
        NetworkManager.getImages(15, text: "flower", page: 2) { (sop, err) in
            for x in sop {
                names.append(x["url_o"].stringValue)
            }
            print(names)
            self.presenter.fill(names)
            self.reloadView()
            self.dismissHUD(isAnimated: false)
        }
        
    }

    func setup() {
        searchBar.placeholder = "Search"

        presenter = ImagesPresenter(viewController: self)
        searchBar.delegate = presenter
        collectionView.dataSource = presenter.datasource
        collectionView.delegate = presenter
        if let text = searchBar.text {
            presenter.searchBar(searchBar, textDidChange: text)
        }
        
        searchBarTopConstrait.constant = 0.0
        addCollectionViewObserver()
    }

    func addCollectionViewObserver() {
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keypath = keyPath, keypath == "contentOffset", let collectionView = object as? UICollectionView {
            searchBarTopConstrait.constant = -1 * collectionView.contentOffset.y
        }
    }

   func reloadView() {
        collectionView.reloadData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        collectionView.removeObserver(self, forKeyPath: "contentOffset")
    }

}
