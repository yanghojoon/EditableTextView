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
        textView.attributedText = NSAttributedString(string: "")
        textView.allowsEditingTextAttributes = true
        return textView
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setAttributes()
        configureSubviewLayout()
    }

    private func setAttributes() {
        view.backgroundColor = .white
        setTextViewAttributes()
        setupKeyboardNotifications()
    }

    private func setTextViewAttributes() {
        textView.delegate = self
    }

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func configureSubviewLayout() {
        view.addSubview(textView)

        textView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let inset = keyboardHeight - view.safeAreaInsets.bottom + 10
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25

        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self else { return }
            self.textView.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(inset)
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25


        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self else { return }
            self.textView.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            }
            self.view.layoutIfNeeded()
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
            let boldAction = UIAction(title: "볼드체") { [weak self] _ in
                self?.toggleBoldStyle(in: range)
            }

            let italicAction = UIAction(title: "Italic") { [weak self] _ in
                self?.toggleItalicStyle(in: range)
            }

            let changeTextColorAction = UIAction(title: "글자색 변경") { [weak self] _ in
                guard let self else { return }
                let picker = UIColorPickerViewController()
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }

            additionalActions.append(boldAction)
            additionalActions.append(italicAction)
            additionalActions.append(changeTextColorAction)
        }

        return UIMenu(children: suggestedActions + additionalActions)
    }

    private func toggleBoldStyle(in range: NSRange) {
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)

        attributedText.enumerateAttribute(.font, in: range, options: []) { (value, range, stop) in
            if let font = value as? UIFont {
                if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
                    let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                    attributedText.addAttribute(.font, value: newFont, range: range)
                }
            } else {
                attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: range)
            }
        }

        let selectedTextRange = textView.selectedTextRange
        textView.attributedText = attributedText
        textView.selectedTextRange = selectedTextRange
    }

    private func toggleItalicStyle(in range: NSRange) {
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)

        attributedText.enumerateAttribute(.font, in: range, options: []) { (value, range, stop) in
            let matrix = CGAffineTransform(a: 1, b: 0, c: 0.25, d: 1, tx: 0, ty: 0)
            let descriptor = UIFont.systemFont(ofSize: 14).fontDescriptor.withMatrix(matrix)
            let newFont = UIFont(descriptor: descriptor, size: 14)
            attributedText.addAttribute(.font, value: newFont, range: range)
        }

        let selectedTextRange = textView.selectedTextRange
        textView.attributedText = attributedText
        textView.selectedTextRange = selectedTextRange
    }
}

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(
        _ viewController: UIColorPickerViewController
    ) {
        applyAttribute(.foregroundColor, value: viewController.selectedColor)
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
