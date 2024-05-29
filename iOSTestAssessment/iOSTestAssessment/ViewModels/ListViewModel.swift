//
//  ListViewModel.swift
//  iOSTestAssessment
//
//  Created by Vikram Jagad on 29/05/24.
//

import UIKit
import Combine

protocol ListViewModelDelegate: NSObjectProtocol {
    func listUpdated()
    func reloadAtIndex(_ index: Int)
}

class ListViewModel: NSObject {
    // MARK: - Constants
    struct Constants {
        static let kDataPerPage = 10
    }

    // MARK: - Private properties
    private weak var delegate: ListViewModelDelegate?
    private var listData: [PostModel] = []
    private var pageIndex = 0
    // MARK: - Public properties
    var list: [DisplayPostModel] = []
    var totalCount: Int = 0
    var selectedId: Int = -1

    // MARK: - Initializer
    init(delegate: ListViewModelDelegate?) {
        self.delegate = delegate
        pageIndex = 0
    }

    // MARK: - Private Methods
    private func updateList(data: [PostModel]) {
        if pageIndex == 0 {
            list.removeAll()
        }
        list.append(contentsOf: data.map({ DisplayPostModel(model: $0,
                                                            attributedTextForList: getAttributedText(id: $0.id, title: $0.title),
                                                            attributedTextForTitle: $0.title.attributedTextWithBlackColor,
                                                            attributedTextForBody: $0.body.attributedTextWithBlackColor) }))
        pageIndex += 1
        delegate?.listUpdated()
    }
    
    private func getAttributedText(id: Int, title: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(id)",
                                                         attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                                                                      NSAttributedString.Key.foregroundColor : UIColor.black])
        attributedString.append(NSAttributedString(string: " "))
        let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
                          NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        if let htmlToAttributedString = title.htmlToAttributedString {
            attributedString.append(NSAttributedString(string: htmlToAttributedString.string,
                                                       attributes: attributes))
        } else {
            attributedString.append(NSAttributedString(string: title,
                                                       attributes: attributes))
        }
        return attributedString
    }

    // MARK: - Public Methods
    func getListData() {
        if pageIndex == 0 {
            Task { [weak self] in
                if let list = await PostModel.getListData() {
                    self?.listData = list
                    self?.totalCount = list.count
                    if let pageIndex = self?.pageIndex {
                        self?.updateList(data: Array(list[pageIndex..<Constants.kDataPerPage]))
                    }
                }
            }
        } else if (pageIndex*Constants.kDataPerPage) >= totalCount {
            return
        } else {
            var upToIndex = ((pageIndex+1)*Constants.kDataPerPage)
            upToIndex = listData.indices.contains(upToIndex - 1) ? upToIndex : totalCount
            updateList(data: Array(listData[(pageIndex*Constants.kDataPerPage)..<upToIndex]))
        }
    }

    func refreshData() {
        pageIndex = 0
        getListData()
    }

    func getDisplayPostModel() -> DisplayPostModel? {
        list.filter({ $0.model.id == selectedId }).first
    }

    func updateModel(_ displayPostModel: DisplayPostModel?) {
        if var displayPostModel = displayPostModel, let index = list
            .firstIndex(where: { $0.model.id == displayPostModel.model.id }) {
            displayPostModel.attributedTextForList = getAttributedText(id: displayPostModel.model.id,
                                                                       title: displayPostModel.model.title)
            listData[index] = displayPostModel.model
            list[index] = displayPostModel
            delegate?.reloadAtIndex(index)
        }
    }
}
