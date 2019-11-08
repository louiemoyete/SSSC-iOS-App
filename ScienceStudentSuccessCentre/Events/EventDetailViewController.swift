//
//  EventDetailViewController.swift
//  ScienceStudentSuccessCentre
//
//  Created by Avery Vine on 2018-02-01.
//  Copyright © 2018 Avery Vine. All rights reserved.
//

import UIKit
import SafariServices
import UserNotifications

class EventDetailViewController: UIViewController {
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventTitleView: UIView!
    @IBOutlet var eventDescriptionTextView: UITextView!
    @IBOutlet var eventDetailsView: UIView!
    @IBOutlet var eventDateTimeLabel: UILabel!
    @IBOutlet var eventLocationLabel: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var eventStackView: UIStackView!
    @IBOutlet var eventScrollView: UIScrollView!
    
    var event: Event? {
        didSet {
            refreshUI()
        }
    }
    var isPreview: Bool = false {
        didSet {
            prepareNavigationBarButtons()
        }
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private var actionUrlButton: UIBarButtonItem {
        let customView = UIButton()
        let width: CGFloat
        let height: CGFloat
        let image: UIImage?
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(scale: .large)
            image = UIImage(systemName: "link", withConfiguration: config)
            width = (image?.size.width ?? 0) + 3
            height = image?.size.height ?? 0
        } else {
            image = UIImage(named: "linkIcon")
            width = 30
            height = 30
            
            customView.widthAnchor.constraint(equalToConstant: width).isActive = true
            customView.heightAnchor.constraint(equalToConstant: height).isActive = true
            customView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        customView.setImage(image, for: .normal)
        customView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        customView.addTarget(self, action: #selector(actionUrlTapped), for: .touchUpInside)
        customView.accessibilityLabel = "External Website: " + (event?.actionUrl ?? "")
        customView.accessibilityTraits = .link
        return UIBarButtonItem(customView: customView)
    }
    
    private var shareButton: UIBarButtonItem {
        if #available(iOS 13.0, *) {
            let customView = UIButton()
            let config = UIImage.SymbolConfiguration(scale: .large)
            let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
            customView.setImage(image, for: .normal)
            customView.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
            customView.frame = CGRect(x: 0, y: 0, width: (image?.size.width ?? 0) + 8, height: image?.size.height ?? 0)
            customView.accessibilityLabel = "Share"
            customView.accessibilityTraits = .button
            return UIBarButtonItem(customView: customView)
        } else {
            return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        }
    }
    
    private func notificationButton(notificationPending: Bool) -> UIBarButtonItem {
        let customView = UIButton()
        let width: CGFloat
        let height: CGFloat
        let image: UIImage?
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(scale: .large)
            image = UIImage(systemName: notificationPending ? "bell.fill" : "bell", withConfiguration: config)
            width = (image?.size.width ?? 0) + 8
            height = image?.size.height ?? 0
            if notificationPending {
                customView.tintColor = UIColor(.amber)
            }
        } else {
            image = UIImage(named: notificationPending ? "notifyOn" : "notifyOff")
            width = 29
            height = 29
            
            customView.widthAnchor.constraint(equalToConstant: width).isActive = true
            customView.heightAnchor.constraint(equalToConstant: height).isActive = true
            customView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        customView.setImage(image, for: .normal)
        customView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        customView.addTarget(self, action: #selector(notifyMeTapped), for: .touchUpInside)
        customView.accessibilityLabel = "Notify Me"
        customView.accessibilityTraits = .button
        let button = UIBarButtonItem(customView: customView)
        button.accessibilityIdentifier = "ToggleNotification"
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        eventDetailsView.isHidden = true
        eventImageView.isHidden = true
        eventTitleView.addBorders(edges: [.bottom], color: UIColor(.bluegrey), width: 1)
        eventDetailsView.addBorders(edges: [.top], color: UIColor(.bluegrey), width: 0.4)
        
        view.sendSubviewToBack(eventStackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigationBarAppearance()
        
        if let event = event {
            notificationCenter.checkPendingNotifications(for: event).done { notificationPending in
                self.prepareNavigationBarButtons(notificationPending: notificationPending)
            }.cauterize()
        }
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        prepareEventDetails()
        prepareNavigationBarButtons()
    }
    
    /// Determines which buttons (action, notification, share) should be added to the navigation bar, if any.
    ///
    /// - If there is an action associated to the event being displayed, the action button is displayed.
    /// - If the notification date/time for this event has not passed, the notification button is displayed.
    /// - If arriving from peek and pop (i.e. `isPreview == true`), no buttons are shown
    private func prepareNavigationBarButtons(notificationPending: Bool = false) {
        var barButtonItems: [UIBarButtonItem] = []
        if let event = event, !isPreview {
            if event.eventUrl != nil {
                barButtonItems.append(shareButton)
            }
            if event.notificationDateTime!.compare(Date()) != ComparisonResult.orderedAscending {
                barButtonItems.append(notificationButton(notificationPending: notificationPending))
            }
            if !(event.actionUrl ?? "").isEmpty {
                barButtonItems.append(actionUrlButton)
            }
            navigationItem.setRightBarButtonItems(barButtonItems, animated: false)
        } else {
            navigationItem.setRightBarButtonItems([], animated: false)
        }
    }
    
    /// Prepares the details of this event to be displayed, including loading in all of the text, the associated image (if any), and adding small borders to various event-related views.
    private func prepareEventDetails() {
        if let event = event {
            eventDetailsView.isHidden = false
            eventDescriptionTextView.delegate = self
            
            eventTitleLabel.text = event.name
            eventDateTimeLabel.text = event.formattedDateAndTime
            eventLocationLabel.text = event.location
            
            eventDescriptionTextView.attributedText = event.description.htmlToAttributedString
            eventDescriptionTextView.font = .preferredFont(forTextStyle: .body)
            
            if event.imageUrl != nil {
                loadImage()
            } else {
                self.eventImageView.isHidden = true
            }
        } else {
            eventDetailsView.isHidden = true
        }
    }
    
    @objc private func notifyMeTapped() {
        notificationCenter.checkAuthorized().done { isAuthorized in
            if isAuthorized {
                self.toggleNotificationEnabled()
            } else {
                // Prompt the user to allow notifications in settings
                let alert = UIAlertController(title: "Notification permissions required",
                                              message: "In order to be notified of events, we need you to grant notification permissions to this app in Settings.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                })
                self.present(alert, animated: true)
            }
        }.cauterize()
    }
    
    private func toggleNotificationEnabled() {
        notificationCenter.checkPendingNotifications(for: self.event!).done { notificationPending in
            let shouldEnableNotification = !notificationPending
            self.prepareNavigationBarButtons(notificationPending: shouldEnableNotification)
            if shouldEnableNotification {
                self.createEventNotification()
            } else {
                self.notificationCenter.removeNotifications(for: self.event!)
            }
        }.cauterize()
    }
    
    /// Delegates opening the actionUrl to the in-app browser when the action button is tapped.
    @objc private func actionUrlTapped() {
        openUrlInAppBrowser(url: URL(string: event?.actionUrl ?? ""))
    }
    
    /// Opens a share sheet that allows the user to share the link to this event.
    @objc private func shareButtonTapped() {
        if let url = event?.eventUrl?.absoluteString {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let popOver = activityVC.popoverPresentationController {
                popOver.barButtonItem = navigationItem.rightBarButtonItems?.first
            }
            self.present(activityVC, animated: true)
        }
    }
    
    private func createEventNotification() {
        notificationCenter.createNotification(for: event!).done { success in
            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController(title: "Notification enabled!",
                                                  message: "You'll be sent a notification an hour before this event starts.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    self.presentGenericError()
                }
            }
            if !success {
                self.prepareNavigationBarButtons(notificationPending: false)
            }
        }.cauterize()
    }
    
    private func loadImage() {
        if let url = event?.imageUrl {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.eventImageView.image = image
                            let ratio = image.size.height / image.size.width
                            let newHeight = self.eventImageView.frame.size.width * ratio
                            self.eventImageView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
                            self.eventImageView.isHidden = false
                        }
                    }
                }
            }
        }
    }
}

extension EventDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        openUrlInAppBrowser(url: URL)
        return false
    }
    
    private func openUrlInAppBrowser(url: URL?) {
        guard let url = url else { return }
        let safariVC = SSSCSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
