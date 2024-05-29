//
//  DetailViewController.swift
//  iOSTestAssessment
//
//  Created by Vikram Jagad on 30/05/24.
//

import UIKit

protocol DetailViewControllerDelegate: NSObjectProtocol {
    func updatedModel(_ displayPostModel: DisplayPostModel?)
    func getDisplayPostModel() -> DisplayPostModel?
}

class DetailViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var labelId: UILabel!
    @IBOutlet weak var textViewTitle: UITextView!
    @IBOutlet weak var textViewBody: UITextView!
    @IBOutlet weak var labelError: UILabel!

    // MARK: - Private properties
    private lazy var viewModel: DetailViewModel = {
        let viewModel = DetailViewModel(delegate: self)
        return viewModel
    }()
    
    // MARK: - Public properties
    weak var delegate: DetailViewControllerDelegate?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }

    // MARK: - Private Methods
    private func setUpViewController() {
        viewModel.displayPostModel = delegate?.getDisplayPostModel()
        labelId.text = viewModel.getId()
        updateTextViewData()
        textViewTitle.delegate = self
        textViewBody.delegate = self
    }

    @IBAction func buttonSaveClickHandler(_ sender: UIButton) {
        if viewModel.isValidData() {
            delegate?.updatedModel(viewModel.displayPostModel)
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - DetailViewModelDelegate Methods
extension DetailViewController: DetailViewModelDelegate {
    func showError(_ message: String) {
        labelError.text = message
        labelError.isHidden = false
    }

    func hideError() {
        labelError.isHidden = true
    }

    func updateTextViewData() {
        textViewTitle.attributedText = viewModel.displayPostModel?.attributedTextForTitle
        textViewBody.attributedText = viewModel.displayPostModel?.attributedTextForBody
    }
}

// MARK: - UITextViewDelegate Methods
extension DetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textFieldString = textView.text, let swtRange = Range(range, in: textFieldString) {
            let fullString = textFieldString.replacingCharacters(in: swtRange, with: text)
            if textView == textViewTitle {
                viewModel.updateText(fullString, type: .title)
            } else if textView == textViewBody {
                viewModel.updateText(fullString, type: .body)
            }
        }
        return true
    }
}
