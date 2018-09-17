// MARK: - AlertWhistler
@available(iOS 9.0, *)
open class AlertWhistler: UIView {
    
    public static var ALERT_WHISTLER_SHOW_DURATION_FOR_NOTICE: TimeInterval = 5.0
    public static var ALERT_WHISTLER_SHOW_DURATION_FOR_WHISPER: TimeInterval = 2.0
    public static var ALERT_WHISTLER_BACKGROUND_COLOR_FOR_NOTICE: UIColor = UIColor.white
    public static var ALERT_WHISTLER_BACKGROUND_COLOR_FOR_WHISPER: UIColor = UIColor.blue
    public static var ALERT_WHISTLER_TEXT_COLOR_FOR_NOTICE: UIColor = UIColor.black
    public static var ALERT_WHISTLER_TEXT_COLOR_FOR_WHISPER: UIColor = UIColor.white
    public static var ALERT_WHISTLER_TEXT_FONT: UIFont = UIFont.systemFont(ofSize: 13)
    public static var ALERT_WHISTLER_DROP_SHADOW_COLOR: UIColor = UIColor.black
    
    static var views: [AlertWhistler] = [AlertWhistler]()
    
    final let animationDuration: TimeInterval = 0.25
    final let sideMargin: CGFloat = 12.0
    final let noticeContentsViewHeight: CGFloat = 44.0
    final let imageViewSize: CGFloat = 36.0
    
    var containerWindow: UIWindow? = UIWindow()
    var stackView: UIStackView!
    var contentsStackView: UIStackView!
    var label: UILabel!
    var imageView: UIImageView!
    
    var showDuration: TimeInterval!
    var didTouchIn: (() -> ())?
    
    fileprivate var dismissTimer: Timer?
    fileprivate var isDismissing: Bool = false
    fileprivate var isWhisper: Bool = false
    
    deinit {
        print("AlertWhistler deinit")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
}



@available(iOS 9.0, *)
extension AlertWhistler {
    
    public class func instance(text: String,
                               imagePath path: String? = nil,
                               duration: TimeInterval? = nil,
                               backgroundColor bgColor: UIColor? = nil,
                               textColor: UIColor? = nil,
                               textFont: UIFont? = nil,
                               shadowColor: UIColor? = nil,
                               isWhisper: Bool = false,
                               touchIn: (() -> ())? = nil) -> AlertWhistler {
        if !hasTopSafeAreaInsets() && isWhisper {
            return whisper(text: text,
                           duration: duration ?? AlertWhistler.ALERT_WHISTLER_SHOW_DURATION_FOR_WHISPER,
                           backgroundColor: bgColor ?? AlertWhistler.ALERT_WHISTLER_BACKGROUND_COLOR_FOR_WHISPER,
                           textColor: textColor ?? AlertWhistler.ALERT_WHISTLER_TEXT_COLOR_FOR_WHISPER,
                           textFont: textFont ?? AlertWhistler.ALERT_WHISTLER_TEXT_FONT)
        } else {
            return notice(text: text,
                          imagePath: path,
                          duration: duration ?? (isWhisper ? AlertWhistler.ALERT_WHISTLER_SHOW_DURATION_FOR_WHISPER : AlertWhistler.ALERT_WHISTLER_SHOW_DURATION_FOR_NOTICE),
                backgroundColor: bgColor ?? AlertWhistler.ALERT_WHISTLER_BACKGROUND_COLOR_FOR_NOTICE,
                textColor: textColor ?? AlertWhistler.ALERT_WHISTLER_TEXT_COLOR_FOR_NOTICE,
                textFont: textFont ?? AlertWhistler.ALERT_WHISTLER_TEXT_FONT,
                shadowColor: shadowColor ?? AlertWhistler.ALERT_WHISTLER_DROP_SHADOW_COLOR,
                touchIn: touchIn)
        }
    }
    
    public class func whisper(text: String,
                              duration: TimeInterval = AlertWhistler.ALERT_WHISTLER_SHOW_DURATION_FOR_WHISPER,
                              backgroundColor bgColor: UIColor = AlertWhistler.ALERT_WHISTLER_BACKGROUND_COLOR_FOR_WHISPER,
                              textColor: UIColor = AlertWhistler.ALERT_WHISTLER_TEXT_COLOR_FOR_WHISPER,
                              textFont: UIFont = UIFont.systemFont(ofSize: 13)) -> AlertWhistler {
        let view = AlertWhistler(frame: .zero)
        view.isWhisper = true
        view.setup(text: text,
                   duration: duration,
                   textColor: textColor,
                   textFont: textFont,
                   backgroundColor: bgColor,
                   shadowColor: nil)
        
        return view
    }
    
    public class func notice(text: String,
                             imagePath path: String? = nil,
                             duration: TimeInterval = AlertWhistler.ALERT_WHISTLER_SHOW_DURATION_FOR_NOTICE,
                             backgroundColor bgColor: UIColor = AlertWhistler.ALERT_WHISTLER_BACKGROUND_COLOR_FOR_NOTICE,
                             textColor: UIColor = AlertWhistler.ALERT_WHISTLER_TEXT_COLOR_FOR_NOTICE,
                             textFont: UIFont = UIFont.systemFont(ofSize: 13),
                             shadowColor: UIColor = AlertWhistler.ALERT_WHISTLER_DROP_SHADOW_COLOR,
                             touchIn: (() -> ())? = nil) -> AlertWhistler {
        let view = AlertWhistler(frame: .zero)
        view.isWhisper = false
        view.setup(text: text,
                   duration: duration,
                   textColor: textColor,
                   textFont: textFont,
                   backgroundColor: bgColor,
                   imagePath: path,
                   shadowColor: shadowColor,
                   touchIn: touchIn)
        return view
    }
    
    public func show() {
        AlertWhistler.views.forEach( { $0.dismiss() } )
        addInContainer()
        let completion: (() -> ()) = {
            self.setupDismissTimer()
            AlertWhistler.views.append(self)
        }
        show {
            completion()
        }
    }
    
    class func hasTopSafeAreaInsets() -> Bool {
        if #available(iOS 11.0, *) {
            if let keyWindow = UIApplication.shared.keyWindow {
                return keyWindow.safeAreaInsets.top > 0.0
            }
        }
        
        return false
    }
    
}

// MARK: - internal function
@available(iOS 9.0, *)
extension AlertWhistler {
    
    fileprivate func setupViews() {
        if label == nil {
            label = UILabel()
        }
        
        if imageView == nil {
            imageView = UIImageView()
        }
        
        imageView.widthAnchor.constraint(equalToConstant: imageViewSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageViewSize).isActive = true
        
        if contentsStackView == nil {
            contentsStackView = UIStackView()
        }
        
        contentsStackView.addArrangedSubview(label)
        contentsStackView.addArrangedSubview(imageView)
        contentsStackView.axis = .horizontal
        contentsStackView.alignment = .center
        contentsStackView.distribution = .fill
        contentsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        if stackView == nil {
            stackView = UIStackView()
        }
        
        stackView.addArrangedSubview(contentsStackView)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
    }
    
    fileprivate func setup(text: String,
                           duration: TimeInterval,
                           textColor: UIColor,
                           textFont: UIFont,
                           backgroundColor bgColor: UIColor,
                           imagePath path: String? = nil,
                           shadowColor: UIColor?,
                           touchIn: (() -> ())? = nil) {
        // common
        didTouchIn = touchIn
        showDuration = duration
        backgroundColor = bgColor
        alpha = 1
        
        // whisper / notice
        if !AlertWhistler.hasTopSafeAreaInsets() && isWhisper {
            whisperSetup(text: text, textColor: textColor, textFont: textFont)
        } else {
            noticeSetup(text: text, textColor: textColor, textFont: textFont, imagePath: path, shadowColor: shadowColor)
        }
    }
    
    fileprivate func addInContainer() {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        containerWindow?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: frame.height)
        containerWindow?.backgroundColor = UIColor.clear
        containerWindow?.windowLevel = UIWindowLevelStatusBar
        containerWindow?.rootViewController = UIViewController()
        containerWindow?.rootViewController?.view.addSubview(self)
        containerWindow?.isHidden = false
    }
    
    fileprivate func setupDismissTimer() {
        dismissTimer = Timer.scheduledTimer(timeInterval: showDuration,
                                            target: self,
                                            selector: #selector(executeDismissTimer),
                                            userInfo: nil,
                                            repeats: false)
    }
    
    fileprivate func dismiss(byTouch: Bool = false) {
        if let index = AlertWhistler.views.index(where: { $0 == self } ) {
            AlertWhistler.views.remove(at: index)
        }
        
        dismiss {
            if byTouch {
                self.didTouchIn?()
            }
            self.reset()
            self.removeFromSuperview()
        }
    }
    
    fileprivate func resetDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
    
    @objc private func executeDismissTimer() {
        dismiss()
    }
    
    fileprivate func show(completion: (() -> ())?) {
        if !AlertWhistler.hasTopSafeAreaInsets() && isWhisper {
            whisperShow(completion: completion)
        } else {
            noticeShow(completion: completion)
        }
    }
    
    fileprivate func dismiss(completion: (() -> ())?) {
        if isDismissing {
            return
        }
        isDismissing = true
        transform = CGAffineTransform.identity
        UIView.animate(withDuration: animationDuration, animations: {
            self.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.bounds.height)
        }) { (result) in
            completion?()
        }
    }
    
    fileprivate func reset() {
        resetDismissTimer()
        didTouchIn = nil
        containerWindow = nil
    }
    
}

// MARK: - whisper
@available(iOS 9.0, *)
extension AlertWhistler {
    
    fileprivate func whisperSetup(text: String,
                                  textColor: UIColor,
                                  textFont: UIFont) {
        isUserInteractionEnabled = false
        
        frame = CGRect(x: 0,
                       y: 0,
                       width: UIScreen.main.bounds.width,
                       height: UIApplication.shared.statusBarFrame.size.height)
        
        var topMargin: CGFloat = 0
        if #available(iOS 11.0, *) {
            if let keyWindow = UIApplication.shared.keyWindow {
                topMargin -= (keyWindow.safeAreaInsets.top)
            }
        }
        
        let hformat = String(format: "H:|-%f-[stackView]-%f-|", sideMargin, sideMargin)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hformat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["stackView" : stackView]))
        
        var vformat: String
        if topMargin == 0 {
            vformat = "V:|[stackView]|"
        } else {
            vformat = String(format: "V:|-(%f)-[stackView]|", topMargin)
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vformat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["stackView" : stackView]))
        
        contentsStackView.spacing = 0
        
        label.text = text
        label.textColor = textColor
        label.font = textFont
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        
        imageView.isHidden = true
    }
    
    fileprivate func whisperShow(completion: (() -> ())?) {
        transform = CGAffineTransform.identity.translatedBy(x: 0, y: -bounds.height)
        alpha = 1
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveLinear, animations: {
            self.transform = CGAffineTransform.identity
        }) { (result) in
            completion?()
        }
    }
    
}

// MARK: - notice
@available(iOS 9.0, *)
extension AlertWhistler {
    
    fileprivate func noticeSetup(text: String,
                                 textColor: UIColor,
                                 textFont: UIFont,
                                 imagePath path: String? = nil,
                                 shadowColor: UIColor?) {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        frame = CGRect(x: 0,
                       y: 0,
                       width: UIScreen.main.bounds.width,
                       height: statusBarHeight + noticeContentsViewHeight)
        
        var topMargin: CGFloat = 0
        if #available(iOS 11.0, *) {
            if let keyWindow = UIApplication.shared.keyWindow {
                topMargin += keyWindow.safeAreaInsets.top
            }
        }
        
        let hformat = String(format: "H:|-%f-[stackView]-%f-|", sideMargin, sideMargin)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hformat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["stackView" : stackView]))
        
        let vformat = String(format: "V:|-(%f)-[stackView]|", topMargin)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vformat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["stackView" : stackView]))
        
        contentsStackView.spacing = 8
        
        label.text = text
        label.textColor = textColor
        label.font = textFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        if let p = path, !p.isEmpty {
            imageView.isHidden = false
            imageView.image(from: p)
        } else {
            imageView.isHidden = true
        }
        
        if let sc = shadowColor {
            layer.shadowColor = sc.cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
            layer.shadowRadius = 2.0
            layer.shadowOpacity = 0.2
        }
        
    }
    
    @objc fileprivate func didTapView() {
        dismiss(byTouch: true)
    }
    
    fileprivate func noticeShow(completion: (() -> ())?) {
        stackView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -bounds.height)
        alpha = 1
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
            self.stackView.transform = CGAffineTransform.identity
        }) { (result) in
            completion?()
        }
    }
    
}
