//
//  PostNewController.swift
//  loop
//
//  Created by Yecol Hsu on 01/09/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import Photos
import MWPhotoBrowser
import MBProgressHUD
import TTTAttributedLabel

import SnapKit
import QuartzCore
import QBImagePickerController

let kPostAvatarSize: CGFloat = 64;
let kPostBadgeSize: CGFloat = 40;
let kPostAvatarSpacing: CGFloat = 12;
let kPostTitleWidth: CGFloat = kScreenW - kPostAvatarSize - 3 * kPostAvatarSpacing - 50;
let kPostTitleLeftMargin: CGFloat = kPostAvatarSpacing * 2 + kPostAvatarSize;
let kPostYOffset: CGFloat = 30;
let kPostContentWidth: CGFloat = kScreenW - 2 * kPostAvatarSpacing

fileprivate let kAttachBtnImageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: -5);

class PostNewController: UIViewController,
        UINavigationControllerDelegate,
        PostAttachFriendsDelegate,
        PostAttachLocationDelegate,
        PostAttachBadgeDelegate,
        UITextViewDelegate,
        UIImagePickerControllerDelegate,
        QBImagePickerControllerDelegate {

    private lazy var scrollView: UIScrollView = { [unowned self] in
        let view = UIScrollView()
        view.isScrollEnabled = true;
        view.showsVerticalScrollIndicator = true;
        view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH);
        view.contentSize = CGSize.init(width: kScreenW, height: kScreenH);
        return view
    }()

    private lazy var avatarImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: CGRect.null)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.asAvatar(size: kPostAvatarSize)
        let avatarURL = AVUser.current()?.avatar?.url ?? "";
        imageView.sd_setImage(with: URL(string: avatarURL), placeholderImage: UIImage(named: "avatar-ph"));
        return imageView
    }()

    private lazy var badgeImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var contentTextView: UITextView = { [unowned self] in
        let textView = UITextView()
        textView.font = fontSystem14;
        textView.text = "kFeedPostNewHint".localized
        textView.textColor = UIColor.lightGray
        textView.delegate = self;
        textView.isScrollEnabled = false;
        return textView
    }()

    private lazy var btnBarView: UIView = { [unowned self] in
        let view = UIView()
        return view
    }()

    private lazy var postView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addShadow();
        return view
    }()

    private lazy var postTitleLabel: TTTAttributedLabel = { [unowned self] in
        let title = TTTAttributedLabel(frame: CGRect.null);
        title.textColor = UIColor.darkGray;
        title.font = fontSystem14;
        let attr = [NSUnderlineStyleAttributeName: false,
                    kCTForegroundColorAttributeName as AnyHashable: CL_LINK_COLOR,
                    NSFontAttributeName: fontSystem14Bold] as [AnyHashable: Any];
        title.linkAttributes = attr;
        title.activeLinkAttributes = attr;
        title.setUserWithFriends(poster: AVUser.current()!, friends: nil);
        return title
    }()

    private lazy var postLocationLabel: UILabel = { [unowned self] in
        let location = UILabel();
        location.font = fontSystem12;
        location.textColor = CL_GREY_FONT;
        location.text = "kFeedPostNewTimeHint".localized
        return location
    }()

    private lazy var attachBadgeBtn: UIButton = {
        let btn = UIButton.init(type: .custom);
        btn.setImage(UIImage.init(named: "attach-badge"), for: .normal);
//        btn.setTitle("Badge", for: .normal);
        btn.titleLabel!.font = fontSystem12
        btn.setTitleColor(CL_GREY_FONT, for: .normal);
        btn.addTarget(self, action: #selector(self.attachBadgeBtnPressed), for: .touchUpInside);
        btn.imageEdgeInsets = kAttachBtnImageEdgeInsets;
        return btn;
    }()

    private lazy var attachCameraBtn: UIButton = {
        let btn = UIButton.init(type: .custom);
        btn.setImage(UIImage.init(named: "attach-camera"), for: .normal);
//        btn.setTitle("Camera", for: .normal);
        btn.titleLabel!.font = fontSystem12
        btn.setTitleColor(CL_GREY_FONT, for: .normal);
        btn.addTarget(self, action: #selector(self.attachCameraBtnPressed), for: .touchUpInside);
        btn.imageEdgeInsets = kAttachBtnImageEdgeInsets;
        return btn;
    }()

    private lazy var attachLibraryBtn: UIButton = {
        let btn = UIButton.init(type: .custom);
        btn.setImage(UIImage.init(named: "attach-photos"), for: .normal);
//        btn.setTitle("Library", for: .normal);
        btn.titleLabel!.font = fontSystem12
        btn.setTitleColor(CL_GREY_FONT, for: .normal);
        btn.addTarget(self, action: #selector(self.attachLibraryBtnPressed), for: .touchUpInside);
        btn.imageEdgeInsets = kAttachBtnImageEdgeInsets;
        return btn;
    }()

    private lazy var attachLocationBtn: UIButton = {
        let btn = UIButton.init(type: .custom);
        btn.setImage(UIImage.init(named: "attach-location"), for: .normal);
//        btn.setTitle("Location", for: .normal);
        btn.titleLabel!.font = fontSystem12
        btn.setTitleColor(CL_GREY_FONT, for: .normal);
        btn.addTarget(self, action: #selector(self.attachLocationBtnPressed), for: .touchUpInside);
        btn.imageEdgeInsets = kAttachBtnImageEdgeInsets;
        return btn;
    }()

    private lazy var attachFriendBtn: UIButton = {
        let btn = UIButton.init(type: .custom);
        btn.setImage(UIImage.init(named: "attach-friends"), for: .normal);
//        btn.setTitle("Friends", for: .normal);
        btn.titleLabel!.font = fontSystem12
        btn.setTitleColor(CL_GREY_FONT, for: .normal);
        btn.addTarget(self, action: #selector(self.attachFriendsBtnPressed), for: .touchUpInside);
        btn.imageEdgeInsets = kAttachBtnImageEdgeInsets;
        return btn;
    }()

    private lazy var postBtn: UIButton = {
        let btn = UIButton.init(type: .custom);
        btn.setTitle("kPost".localized, for: .normal);
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 25);
        btn.setLoopBtnGreenFramed(font: fontMontserrat14);
        btn.addTarget(self, action: #selector(self.postBtnPressed), for: .touchUpInside);
        return btn;
    }()

    private lazy var separateLine: UIView = {
        let line = UIView();
        line.backgroundColor = CL_GREY_BG_EC
        return line;
    }()


//    let attachedImage = UIImageView();
//    let postPhotoView = CollageView();


    // for post
    var attachedFriends: [String] = [];
    var attachedLocation: LPPlace?;
    var attachedBadge: LPBadge?;

    var attachedImages = NSMutableArray();
    var attachedImageViews = NSMutableArray();
    var attachedImageViewConstraints = NSMutableArray();
    var lastLayoutElement: UIView?;

    var delegate: PostControllerDelegate?

//    var libraryPhotos: NSMutableArray?
//    var libraryPhotoSelections: NSMutableArray?;
//
//    var pickerPhotos = NSMutableArray();
//    var pickerThumbs = NSMutableArray();


//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }


    override func viewDidLoad() {

        super.viewDidLoad()
        self.title = "kTitle_PostNew".localized
        self.view.backgroundColor = CL_GREY_BG_EC

        let postButtonItem = UIBarButtonItem.init(customView: postBtn)
        self.navigationItem.rightBarButtonItem = postButtonItem;
        let cancelButtonItem = UIBarButtonItem.init(title: "kCancel".localized, style: UIBarButtonItemStyle.plain,
                target: self, action: #selector(self.cancelBtnPressed))
        self.navigationItem.leftBarButtonItem = cancelButtonItem
        self.navigationController?.navigationBar.tintColor = CL_GREEN_DEFAULT

        self.scrollView.addSubview(postView);
        self.scrollView.addSubview(avatarImageView);

        self.scrollView.addSubview(postTitleLabel);
        self.scrollView.addSubview(postLocationLabel);
        self.scrollView.addSubview(badgeImageView);
        self.scrollView.addSubview(contentTextView);
//        self.scrollView.addSubview(postPhotoView);

        self.btnBarView.addSubview(self.attachBadgeBtn);
        self.btnBarView.addSubview(self.attachCameraBtn);
        self.btnBarView.addSubview(self.attachLibraryBtn);
        self.btnBarView.addSubview(self.attachLocationBtn);
        self.btnBarView.addSubview(self.attachFriendBtn);
        self.btnBarView.addSubview(self.separateLine);

        self.postView.addSubview(self.btnBarView);
        self.lastLayoutElement = self.postView;

        self.view.addSubview(self.scrollView);
        self.addLayoutConstraints();
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }

    private func addLayoutConstraints() {
        self.postView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(kPostYOffset);
            make.centerX.equalToSuperview();
            make.width.equalToSuperview()
            make.bottom.equalTo(self.btnBarView)
        }

        self.avatarImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.postView).offset(-20);
            make.left.equalTo(self.postView).offset(kPostAvatarSpacing)
            make.width.equalTo(kPostAvatarSize)
            make.height.equalTo(kPostAvatarSize);
        }

        self.badgeImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.postView).offset(kPostAvatarSpacing);
            make.right.equalTo(self.postView).offset(-kPostAvatarSpacing)
            make.width.equalTo(kPostBadgeSize)
            make.height.equalTo(kPostBadgeSize);
        }

        self.postTitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.postView).offset(10);
            make.left.equalTo(self.postView).offset(kPostTitleLeftMargin)
            make.width.equalTo(kPostTitleWidth)
        }

        self.postLocationLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.postTitleLabel.snp.bottom).offset(5);
            make.left.equalTo(self.postTitleLabel)
            make.width.equalTo(kPostTitleWidth)
        }

        self.contentTextView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.postLocationLabel.snp.bottom).offset(5);
            make.width.equalTo(kPostContentWidth)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(90);
        }

        self.btnBarView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentTextView.snp.bottom).offset(5);
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }

        self.attachBadgeBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.width.equalTo(kScreenW / 5)
            make.height.equalToSuperview()
            make.left.equalToSuperview();
        }
        
        self.attachCameraBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.width.equalTo(kScreenW / 5)
            make.height.equalToSuperview()
            make.left.equalTo(self.attachBadgeBtn.snp.right);
        }

        self.attachLibraryBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.width.equalTo(kScreenW / 5)
            make.height.equalToSuperview()
            make.left.equalTo(self.attachCameraBtn.snp.right);
        }

        self.attachLocationBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.width.equalTo(kScreenW / 5)
            make.height.equalToSuperview()
            make.left.equalTo(self.attachLibraryBtn.snp.right);
        }

        self.attachFriendBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.width.equalTo(kScreenW / 5)
            make.height.equalToSuperview()
            make.left.equalTo(self.attachLocationBtn.snp.right)
        }

        self.separateLine.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
        }

    }


    func cancelBtnPressed() {
        self.dismiss(animated: true, completion: nil);
    }


    func postBtnPressed() {
        let content = self.contentTextView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);

        if (self.attachedBadge == nil) {
            self.displayAlertView("kRulePostMustHaveBadge".localized);
            return;
        } else if (content == nil || content == "kFeedPostNewHint".localized ||
                content!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "") {
            self.displayAlertView("kRulePostMustHaveContent".localized);
            return;
        } else if (self.attachedImages.count == 0) {
            self.displayAlertView("kRulePostMustHaveImages".localized);
            return;
        } else {
//            let imageData = NSData(self.postAttachedImage.)

            var attachedImageIds: [String] = [];

            self.showProgress()

            for image in self.attachedImages {
                let scaledImage = UIImage.resizeWithImage(image as! UIImage, toWidth: kPostPhotoMaxWidth);
                let imageData = UIImageJPEGRepresentation(scaledImage, kPostPhotoJPEGQuality);
                let file = AVFile(data: imageData!);
                file.save();
                if (file.objectId == nil) {
                    self.displayAlertView("kAlert_UploadPhotoFailed".localized);
                    return;
                } else {
                    attachedImageIds.append(file.objectId!);
                }
            }

            self.postBtn.isEnabled = false;

            var error: NSError?

            DataModelManager.sharedInstance.cloudCreatePost(message: content!, photos: attachedImageIds,
                    friends: attachedFriends, badge: attachedBadge, place: attachedLocation, errorPtr: &error);

            self.hideProgress();
            self.showComplete(with: "kToastPostNewSuccess".localized)

            if let actualError = error {
                self.displayAlertView("An Error Occurred: \(actualError)")
            } else {
                self.dismiss(animated: true, completion: nil);
                self.delegate?.dismissSilently();
            }
        }
    }

    func attachBadgeBtnPressed() {
        let flowLayout = UICollectionViewFlowLayout();
        let badgesList = PostAttachBadgeController(collectionViewLayout: flowLayout);
        badgesList.delegate = self;
        let badgesListNav = UINavigationController.init(rootViewController: badgesList);
        self.present(badgesListNav, animated: true, completion: nil);
    }

    func attachLibraryBtnPressed() {
        self.clearAttachedImages();
        let imagePickerController = QBImagePickerController();
        imagePickerController.delegate = self;
        imagePickerController.view.tintColor = CL_GREEN_DEFAULT
        imagePickerController.allowsMultipleSelection = true;
        imagePickerController.maximumNumberOfSelection = 6;
        imagePickerController.showsNumberOfSelectedAssets = true;
        self.present(imagePickerController, animated: true, completion: nil);
    }
    
    func attachCameraBtnPressed() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.clearAttachedImages();
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            self.displayAlertView("kAlert_CameraLaunchFailed".localized);
        }
    }
    

    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }


    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        for asset in assets as! [PHAsset] {
            let image = getAssetThumbnail(asset: asset);
            self.selectOneImage(image);
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil);
        //Image picker for nil value
        let selectedImage = info[UIImagePickerControllerOriginalImage];
        if(selectedImage != nil){
            self.selectOneImage(selectedImage as! UIImage);
        }
    }

    private func clearAttachedImages() {
        self.attachedImages.removeAllObjects();
        for item in self.attachedImageViews {
            let imageView = item as! UIView;
            imageView.removeFromSuperview();
        }
        self.attachedImageViews.removeAllObjects();
        self.lastLayoutElement = self.postView;
        self.scrollView.contentSize = CGSize.init(width: kScreenW, height: kScreenH);
    }

    private func selectOneImage(_ image: UIImage) {
        self.attachedImages.add(image);
        let expectHeight:CGFloat = kScreenW * image.size.height / image.size.width
        let spacing:CGFloat = (self.lastLayoutElement == self.postView ? 15:5)
        
        let yorigin = self.lastLayoutElement!.frame.origin.y + self.lastLayoutElement!.frame.height + spacing;
        let frame = CGRect.init(x: 0, y: yorigin, width: kScreenW, height: expectHeight)
        let imageView = UIImageView.init(frame: frame);
        imageView.image = image;
        self.attachedImageViews.add(imageView);
        let expectedContentHeight = yorigin + spacing + expectHeight;
        self.scrollView.addSubview(imageView);
        self.scrollView.contentSize = CGSize.init(width: kScreenW, height: expectedContentHeight);
        self.lastLayoutElement = imageView;
    }


    func attachFriendsBtnPressed() {
        let friendList = PostAttachFriendsController(style: .grouped);
        friendList.delegate = self;
        let friendListNav = UINavigationController.init(rootViewController: friendList);
        self.present(friendListNav, animated: true, completion: nil);
    }


    func attachLocationBtnPressed() {
        let locationList = PostAttachLocationController(style: .grouped);
        locationList.delegate = self;
        let locationListNav = UINavigationController.init(rootViewController: locationList);
        self.present(locationListNav, animated: true, completion: nil);
    }

    func attachLocation(_ place: LPPlace) {
        self.attachedLocation = place;
        self.postLocationLabel.text = "kFeedPostNewTimeHint".localized + " · " + (place.name ?? "");
    }

    func attachFriends(_ friends: NSArray) {

        for friend in friends {
            self.attachedFriends.append((friend as! AVUser).objectId!);
        }
        self.postTitleLabel.setUserWithFriends(poster: AVUser.current()!, friends: friends)
//        self.layout()
//        self.view.setNeedsLayout();
    }


//    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
//        let selectedImage: UIImage = image
//        //var tempImage:UIImage = editingInfo[UIImagePickerControllerOriginalImage] as UIImage
////        self.postAttachedImage = selectedImage
//        self.selectedImages.add(selectedImage);
//        postPhotoView.setPhotos(self.selectedImages);
//
//        self.layout();
//        self.dismiss(animated: true, completion: nil)
//    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func textViewDidChange(_ textView: UITextView) {
//        if (textView.sizeThatFits(CGSize.init(width: kPostContentWidth, height: 1000)).height > 60) {
//            layout();
//        }
//    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.text.characters.count + (text.characters.count - range.length) > 500) {
            self.showToast(with: "kRulePostContentLimit".localized);
            return false;
        } else {
            return true;
        }
    }

//    - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//    {
//    return textView.text.length + (text.length - range.length) <= 140;
//    }

    func attachBadge(_ badge: LPBadge) {
        self.attachedBadge = badge;
        let badgeUrl = badge.smallIcon?.url ?? ""
        badgeImageView.sd_setImage(with: URL.init(string: badgeUrl),
                placeholderImage: UIImage.init(named: "ph-badge"));
    }


//    func selectPhotosBtnPressed() {
//        let status = PHPhotoLibrary.authorizationStatus();
//        if (status == .notDetermined) {
//            PHPhotoLibrary.requestAuthorization({
//                status in
//                if (status == .authorized) {
//                    self.performLoadAssets();
//                }
//            })
//        } else if (status == .authorized) {
//            self.performLoadAssets();
//        } else {
//            self.displayAlertView("not authorized photos")
//        }
//
//    }


//    func presentPhotoPicker() {
//
//        let displayActionButton = true;
//        let displaySelectionButtons = false;
//        let displayNavArrows = false;
//        let enableGrid = true;
//        let startOnGrid = false;
//        let autoPlayOnAppear = false;
//
//        let scale = UIScreen.main.scale;
//        // Sizing is very rough... more thought required in a real implementation
//        let imageSize = max(kScreenW, kScreenH) * 1.5;
//        let imageTargetSize = CGSize.init(width: imageSize * scale, height: imageSize * scale);
//        let thumbTargetSize = CGSize.init(width: imageSize / 3.0 * scale, height: imageSize / 3.0 * scale);
//
//
//        for element in self.libraryPhotos! {
//            let asset = element as! PHAsset;
//            pickerPhotos.add(MWPhoto.init(asset: asset, targetSize: imageTargetSize));
//            pickerThumbs.add(MWPhoto.init(asset: asset, targetSize: thumbTargetSize));
//        }
//
//        let browser = MWPhotoBrowser.init(delegate: self)!
//        browser.displayActionButton = displayActionButton;
//        browser.displayNavArrows = displayNavArrows;
//        browser.displaySelectionButtons = displaySelectionButtons;
//        browser.alwaysShowControls = displaySelectionButtons;
//        browser.zoomPhotosToFill = true;
//        browser.enableGrid = enableGrid;
//        browser.startOnGrid = startOnGrid;
//        browser.enableSwipeToDismiss = false;
//        browser.autoPlayOnAppear = autoPlayOnAppear;
//        browser.setCurrentPhotoIndex(0);
//
//
//        let nc = UINavigationController.init(rootViewController: browser);
//        self.present(nc, animated: true, completion: nil);
//    }
//
//    public func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
//        if (Int(index) < libraryPhotos!.count) {
//            return pickerPhotos.object(at: Int(index)) as! MWPhoto;
//        } else {
//            return nil;
//        }
//    }
//
//    public func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
//        return UInt(libraryPhotos!.count);
//    }



//    func loadAssets() {
//
//        // Check library permissions
//        let status = PHPhotoLibrary.authorizationStatus();
//        if (status == .notDetermined) {
//            PHPhotoLibrary.requestAuthorization({
//                status in
//                if(status == .authorized) {
//                    self.performLoadAssets();
//                }
//            })
//        }
//            else if(status == .authorized) {
//            self.performLoadAssets();
//        }
//            else {
//                self.displayAlertView("not authorized photos")
//        }
//    }

//    func performLoadAssets() {
//
//        // Initialise
//        libraryPhotos = NSMutableArray();
//
//        // Photos library iOS >= 8
////        let priority = DispatchQueue.GlobalQueuePriority.default
//        DispatchQueue.global(qos: .default).async {
//            let options = PHFetchOptions();
//            options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)];
//            let fetchResults = PHAsset.fetchAssets(with: options);
//            fetchResults.enumerateObjects({ obj, idx, stop in
//                self.libraryPhotos!.add(obj);
//            })
//            if (fetchResults.count > 0) {
//                DispatchQueue.main.async {
//                    print("present photo picker in main thread.")
//                    self.presentPhotoPicker()
//                }
//            }
//        };
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: kPostPhotoMaxWidth, height: kPostPhotoMaxWidth * 2),
                contentMode: .aspectFit, options: option, resultHandler: { (result, info) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }

}
