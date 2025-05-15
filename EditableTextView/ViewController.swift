//
//  ViewController.swift
//  EditableTextView
//
//  Created by 양호준 on 5/15/25.
//

import UIKit

import SnapKit

final class ViewController: UIViewController {
    private let textView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setAttributes()
        configureSubviewLayout()
    }

    private func setAttributes() {
        view.backgroundColor = .white
        setTextViewAttributes()
    }

    private func setTextViewAttributes() {
        textView.delegate = self
    }

    private func configureSubviewLayout() {
        view.addSubview(textView)

        textView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        editMenuForTextIn range: NSRange,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        var additionalActions = [UIMenuElement]()

        if range.length > 0 {
            let boldAction = UIAction(title: "Bold") { [weak self] _ in
                self?.applyAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14))
            }

            additionalActions.append(boldAction)
        }

        return UIMenu(children: suggestedActions + additionalActions)
    }

    private func applyAttribute(_ key: NSAttributedString.Key, value: Any) {
        guard let selectedRange = textView.selectedTextRange else { return }

        let nsRange = NSRange(
            location: textView.offset(from: textView.beginningOfDocument, to: selectedRange.start),
            length: textView.offset(from: selectedRange.start, to: selectedRange.end)
        )

        if nsRange.length > 0 {
            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableAttributedString.addAttribute(key, value: value, range: nsRange)
            textView.attributedText = mutableAttributedString
        }
    }
}
