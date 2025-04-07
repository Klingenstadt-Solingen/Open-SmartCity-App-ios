//
//  LegallyViewController.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 06.10.22.
//

import OSCAEssentials
import UIKit

final class LegallyViewController: UIViewController {
  
  @IBOutlet private var textView: UITextView!
  @IBOutlet private var textViewHeight: NSLayoutConstraint!
  
  private var viewModel: LegallyViewModel!
  
  override func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLoad()
    setupViews()
    viewModel.viewDidLoad()
  }
  
  private func setupViews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    title = viewModel.screenTitle
    
    textView.isScrollEnabled = false
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    
    guard let attrString = try? NSMutableAttributedString(
      HTMLString: viewModel.text,
      color: .label)
    else { return }
    
    textView.attributedText = attrString
    textView.linkTextAttributes = [.foregroundColor: UIColor.primary]
    
    textViewHeight.constant = textView.sizeThatFits(textView.frame.size).height
    
    view.layoutIfNeeded()
  }
  
  public override func viewDidLayoutSubviews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLayoutSubviews()
    
    textViewHeight.constant = textView.sizeThatFits(textView.frame.size).height
    view.layoutIfNeeded()
  }
}

// MARK: - instantiate view controller
extension LegallyViewController: StoryboardInstantiable {
  public static func create(with viewModel: LegallyViewModel) -> LegallyViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }
}
