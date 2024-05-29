//
//  ViewController.swift
//  iOSTestAssessment
//
//  Created by Vikram Jagad on 29/05/24.
//

import UIKit

class ListViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Private properties
    private lazy var viewModel: ListViewModel = {
        let viewModel = ListViewModel(delegate: self)
        return viewModel
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Constants
    struct StringConstants {
        static let kListTableViewCell = "ListTableViewCell"
        static let kDetail = "Detail"
        static let kDetailViewController = "DetailViewController"
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }

    // MARK: - Private Methods
    private func setUpViewController() {
        setUpTableViewController()
        viewModel.getListData()
    }

    private func setUpTableViewController() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: StringConstants.kListTableViewCell)
    }
    
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        viewModel.refreshData()
        refreshControl.endRefreshing()
    }
}

// MARK: - UITableViewDelegate Methods
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.list.count - 1 {
            viewModel.getListData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedId = viewModel.list[indexPath.row].model.id
        if let detailViewController = UIStoryboard(name: StringConstants.kDetail, bundle: .main)
            .instantiateViewController(withIdentifier: StringConstants.kDetailViewController) as? DetailViewController {
            detailViewController.delegate = self
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource Methods
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StringConstants.kListTableViewCell,
                                                 for: indexPath)
        if viewModel.list.indices.contains(indexPath.row) {
            let item = viewModel.list[indexPath.row]
            cell.selectionStyle = .none
            cell.textLabel?.attributedText = item.attributedTextForList
            cell.textLabel?.numberOfLines = 0
        }
        return cell
    }
}

// MARK: - ListViewModelDelegate Methods
extension ListViewController: ListViewModelDelegate {
    func listUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    func reloadAtIndex(_ index: Int) {
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

extension ListViewController: DetailViewControllerDelegate {
    func updatedModel(_ displayPostModel: DisplayPostModel?) {
        viewModel.updateModel(displayPostModel)
    }
    
    func getDisplayPostModel() -> DisplayPostModel? {
        return viewModel.getDisplayPostModel()
    }
}
