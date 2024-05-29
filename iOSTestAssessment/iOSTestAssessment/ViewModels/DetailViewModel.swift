//
//  DetailViewModel.swift
//  iOSTestAssessment
//
//  Created by Vikram Jagad on 30/05/24.
//

import UIKit

protocol DetailViewModelDelegate: NSObjectProtocol {
    func showError(_ message: String)
    func hideError()
    func updateTextViewData()
}

class DetailViewModel: NSObject {
    // MARK: - Constants
    struct StringConstants {
        static let kEnterValidTitle = "Please enter valid title"
        static let kEnterValidBody = "Please enter valid body"
        static let kIdNotFound = "Id not found"
    }

    // MARK: - Enum
    enum TextViewType {
        case title
        case body
    }

    // MARK: - Private properties
    private weak var delegate: DetailViewModelDelegate?

    // MARK: - Public properties
    var displayPostModel: DisplayPostModel?

    // MARK: - Initializers
    init(delegate: DetailViewModelDelegate) {
        self.delegate = delegate
    }

    // MARK: - Public Methods
    func getId() -> String {
        return displayPostModel?.model.id != nil ? "\(displayPostModel!.model.id)" : StringConstants.kIdNotFound
    }

    func updateText(_ text: String, type: TextViewType) {
        if text.isEmpty {
            switch type {
            case .title:
                delegate?.showError(StringConstants.kEnterValidTitle)
            case .body:
                delegate?.showError(StringConstants.kEnterValidBody)
            }
        } else {
            delegate?.hideError()
        }
        switch type {
        case .title:
            displayPostModel?.model.title = text
            displayPostModel?.attributedTextForTitle = text.attributedTextWithBlackColor
        case .body:
            displayPostModel?.model.body = text
            displayPostModel?.attributedTextForBody = text.attributedTextWithBlackColor
        }
    }

    func isValidData() -> Bool {
        return !(displayPostModel?.model.title.isEmpty ?? true) && !(displayPostModel?.model.body.isEmpty ?? true)
    }
}
