//
//  RegisterDetailController.swift
//  loop
//
//  Created by Yecol Hsu on 07/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import RSKImageCropper
import IQKeyboardManagerSwift
import SnapKit
import SwiftValidator

fileprivate let kCellHeader = "kCellHeader"
fileprivate let kCellItem = "kCellItem"
fileprivate let kCellButton = "kCellButton"

fileprivate let kPickerDate = 1031;
fileprivate let kPickerGender = 1032;
fileprivate let kInputFirstName = 1033;
fileprivate let kInputLastName = 1034;
fileprivate let kInputLocation = 1035;
fileprivate let kInputDescription = 1036;

class RegisterDetailController: UITableViewController,
        UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        RSKImageCropViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {


    var avatarImage: UIImage?;
    var firstName: String?;
    var lastName: String?;
    var location: String?;
    var descSentence: String?;
    var gender: Int?;
    var birthDay: Date?;

    var itemKeys = NSArray(arrayLiteral: "", "kFirstName".localized, "kLastName".localized, "kGender".localized, "kBirthday".localized, "kCity".localized, "kIntro".localized)
    var itemValue = NSMutableArray();

    var genderOpt = ["kUnspecified".localized, "kMale".localized, "kFemale".localized];

    var updateProfileView = false;
    var updatedAvatar = false;

    weak var dateTextInput: UITextField?;
    weak var genderTextInput: UITextField?;
    weak var datePicker: UIDatePicker?;

    let validator = Validator()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = CL_GREY_BG_EC;

        self.automaticallyAdjustsScrollViewInsets = false;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);

        self.tableView.estimatedRowHeight = 80;
        self.tableView.rowHeight = UITableViewAutomaticDimension;

        self.tableView.register(ProfileDetailHeaderCell.self, forCellReuseIdentifier: kCellHeader);
        self.tableView.register(ProfileDetailItemCell.self, forCellReuseIdentifier: kCellItem);
        self.tableView.register(ProfileDetailButtonCell.self, forCellReuseIdentifier: kCellButton);

        self.setDefaultValues()

//        print("current user = ", AVUser.current() ?? "no user");
//        self.currentUserName.text = AVUser.current()?.username;
//
//        self.avatarImageView.asAvatar();
//        self.avatarImageView.layer.borderColor = UIColor.white.cgColor;
        // Do any additional setup after loading the view.

        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
    }

    func setDefaultValues() {
        if (self.updateProfileView == true) {
            self.title = "kTitle_EditMyDetail".localized
            firstName = AVUser.current()!.firstName!
            lastName = AVUser.current()!.lastName!;
            location = AVUser.current()!.city!;
            descSentence = AVUser.current()!.introduction!;
            gender = AVUser.current()!.gender;
            birthDay = AVUser.current()!.birth;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7;
        default:
            return 1;
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude;
        } else {
            return FL_SEPARATOR_HEIGHT / 2;
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FL_SEPARATOR_HEIGHT / 2;
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let headerCell = tableView.dequeueReusableCell(withIdentifier: kCellHeader, for: indexPath) as! ProfileDetailHeaderCell;
                headerCell.delegate = self;
                headerCell.addLayoutConstrains();
                if (updateProfileView) {
                    headerCell.setAvatarImage(urlString: AVUser.current()!.avatar?.url ?? "");
                }
                return headerCell;
            default:
                let itemCell = tableView.dequeueReusableCell(withIdentifier: kCellItem, for: indexPath) as!
                ProfileDetailItemCell;
                let itemKey = itemKeys.object(at: indexPath.row) as! String;
                itemCell.delegate = self;
                itemCell.bindData(itemKey, itemValue: nil);
                return itemCell;
            }
        default:
            let buttonCell = tableView.dequeueReusableCell(withIdentifier: kCellButton, for: indexPath);
            return buttonCell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row != 0 {
            let itemCell = tableView.cellForRow(at: indexPath) as! ProfileDetailItemCell;
            itemCell.selectToEdit();
        }
        if indexPath.section == 1 {
            self.updateBtnPressed();
        }
        tableView.deselectRow(at: indexPath, animated: true);
    }


    func changeAvatarBtnPressed() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func updateAvatarDisplay() {
        let indexPath = IndexPath(row: 0, section: 0);
        let cell = self.tableView.cellForRow(at: indexPath) as! ProfileDetailHeaderCell;
        cell.bindData(self.avatarImage!, username: self.firstName ?? "User")
//        self.tableView.reloadRows(at: [indexPath], with: .none);
    }

    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!,
                               editingInfo: NSDictionary!) {
        self.avatarImage = image
        self.updatedAvatar = true
        self.dismiss(animated: true, completion: nil)

        let imageCropVC = RSKImageCropViewController(image: self.avatarImage!, cropMode: .circle)
        imageCropVC.delegate = self;
        self.navigationController?.pushViewController(imageCropVC, animated: true);
    }

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        _ = self.navigationController?.popViewController(animated: true);
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage,
                                 usingCropRect cropRect: CGRect) {
        self.avatarImage = croppedImage;
        self.updatedAvatar = true;
        self.updateAvatarDisplay()
        _ = self.navigationController?.popViewController(animated: true);
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage,
                                 usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.avatarImage = croppedImage;
        self.updateAvatarDisplay()
        _ = self.navigationController?.popViewController(animated: true);
    }


    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
//        print("cropping.")
    }


    // picker delegat

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == kPickerGender) {
            return genderOpt.count;
        }
        return 0;
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == kPickerGender) {
            return genderOpt[row];
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == kPickerGender) {
            self.genderTextInput!.text = genderOpt[row];
            self.gender = row;
        }
    }


    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == kInputFirstName) {
            self.firstName = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
        } else if (textField.tag == kInputLastName) {
            self.lastName = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
        } else if (textField.tag == kInputLocation) {
            self.location = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
        } else if (textField.tag == kInputDescription) {
            self.descSentence = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
        }
    }

    func updateDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = dateFormatter.string(from: self.datePicker!.date)
        self.dateTextInput!.text = dateString;
        self.birthDay = self.datePicker!.date;
    }

    func updateBtnPressed() {

        IQKeyboardManager.sharedManager().resignFirstResponder()

        if (self.updateProfileView == false && self.avatarImage == nil) {
            self.displayAlertView("kAlert_ProfileDetailAvatarNeeded".localized);
            return;
        }


        self.validator.validate({ errors in
            if (errors.count == 0) {
                self.requestForSignupDetails(self.firstName!, ln: self.lastName!, desc: self.descSentence!,
                        city: self.location!, birth: self.birthDay!, gender: self.gender!);
            } else {
                for (field, error) in errors {
                    self.displayAlertView("kAlert_ProfileDetailAllFieldMandatory".localized);
                    return;
                }
            }
        });
    }


    func requestForSignupDetails(_ fn: String, ln: String, desc: String, city: String, birth: Date, gender: Int) {

        var error: NSError?
        if (updatedAvatar == true) {
            let aImage = UIImage.resizeWithImage(self.avatarImage!, toWidth: kAvatarMaxWidth);
            let imageData: Data = UIImagePNGRepresentation(aImage)!;
            let file = AVFile(data: imageData)
            file.save(&error);
            if (self.filterError(error as Error?)) {
                let me = AVUser.current()
                me?.avatar = file;
                me?.birth = birth;
                me?.firstName = fn;
                me?.lastName = ln;
                me?.city = city;
                me?.introduction = desc;
                me?.gender = gender;
                me?.save(&error)
                if (self.filterError(error)) {
                    self.showToast(with: "kToastProfileEditSavedSuccess".localized);
                    if (updateProfileView) {
                        self.navigationController?.popViewController(animated: true);
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            let me = AVUser.current()
            me?.birth = birth;
            me?.firstName = fn;
            me?.lastName = ln;
            me?.city = city;
            me?.introduction = desc;
            me?.gender = gender;
            me?.save(&error)
            if (self.filterError(error)) {
                self.showToast(with: "kToastProfileEditSavedSuccess".localized);
                if (updateProfileView) {
                    self.navigationController?.popViewController(animated: true);
                } else {
                    self.dismiss(animated: true, completion: nil);
                }
            }
        }
    }

}

fileprivate let kProfileEditAvatarSize: CGFloat = 96.0
fileprivate let kProfileEditAvatarPadding: CGFloat = 24.0
fileprivate let kProfileEditAvatarTopPadding: CGFloat = 120.0

private class ProfileDetailHeaderCell: UITableViewCell {

    var delegate: RegisterDetailController?;

    private lazy var avatarImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill;
        imageView.layer.borderColor = UIColor.white.cgColor;
        imageView.layer.cornerRadius = kProfileEditAvatarSize / 2;
        imageView.layer.borderWidth = 2.0
        imageView.clipsToBounds = true;
        imageView.backgroundColor = CL_GREEN_ASSISTANCE;
        return imageView
    }()

    private lazy var avatarEditButton: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "change-avatar"), for: .normal);
        button.addTarget(self.delegate, action: #selector(self.delegate!.changeAvatarBtnPressed), for: .touchUpInside)
        return button
    }()

    private lazy var welcomeLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "kRegisterDetailWelcome".localized
        label.font = fontMontserrat24Bold
        label.textColor = UIColor.white;
        return label
    }()

    private lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = fontMontserrat24Bold
        label.textColor = UIColor.white;
        return label
    }()

    private lazy var detailLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "kRegisterDetailWelcomeDetail".localized
        label.font = fontSystem14
        label.textColor = UIColor.white;
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none;
        self.backgroundColor = CL_GREEN_BG;
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.avatarEditButton);
        self.contentView.addSubview(self.welcomeLabel)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.detailLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(_ avatar: UIImage?, username: String) {
        if avatar != nil {
            self.avatarEditButton.setImage(nil, for: .normal);
            self.avatarImageView.image = avatar!;
        }
        self.nameLabel.text = username;
    }

    func setAvatarImage(urlString: String) {
        self.avatarEditButton.setImage(nil, for: .normal);
        self.avatarImageView.sd_setImage(with: URL.init(string: urlString));
    }

    func addLayoutConstrains() {

        if(self.delegate!.updateProfileView == false) {
            self.avatarImageView.snp.makeConstraints { (make) -> Void in
                make.top.equalToSuperview().offset(kProfileEditAvatarTopPadding)
                make.left.equalToSuperview().offset(kProfileEditAvatarPadding);
                make.bottom.equalTo(self.contentView).offset(-kProfileEditAvatarPadding)
                make.width.equalTo(kProfileEditAvatarSize)
                make.height.equalTo(kProfileEditAvatarSize)
            }

            self.avatarEditButton.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.avatarImageView)
                make.left.equalTo(self.avatarImageView)
                make.size.equalTo(self.avatarImageView)
            }

            self.welcomeLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.avatarImageView)
                make.left.equalTo(self.avatarImageView.snp.right).offset(kProfileEditAvatarPadding);
            }

            self.nameLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.welcomeLabel.snp.bottom).offset(10);
                make.left.equalTo(self.welcomeLabel)
            }

            self.detailLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.nameLabel.snp.bottom).offset(10);
                make.left.equalTo(self.nameLabel)
                make.bottom.lessThanOrEqualToSuperview().offset(-kProfileEditAvatarPadding)
            }
        }
        else{

            self.avatarImageView.snp.makeConstraints { (make) -> Void in
                make.top.equalToSuperview().offset(kProfileEditAvatarTopPadding - 20)
                make.centerX.equalToSuperview();
                make.bottom.equalTo(self.contentView).offset(-kProfileEditAvatarPadding)
                make.width.equalTo(kProfileEditAvatarSize)
                make.height.equalTo(kProfileEditAvatarSize)
            }

            self.avatarEditButton.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.avatarImageView)
                make.left.equalTo(self.avatarImageView)
                make.size.equalTo(self.avatarImageView)
            }

            self.welcomeLabel.removeFromSuperview();
            self.nameLabel.removeFromSuperview();
            self.detailLabel.removeFromSuperview();
            self.backgroundColor = UIColor.white

        }
    }
}

class ProfileDetailItemCell: UITableViewCell {

    var delegate: RegisterDetailController?;

    private lazy var itemKey: UILabel = { [unowned self] in
        let label = UILabel()
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem16SemiBold;
        return label
    }()

    private lazy var itemValue: UITextField = { [unowned self] in
        let input = UITextField();
        input.textColor = CL_BLACK_GRACE;
        input.font = fontSystem16;
        return input
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none;
        self.contentView.addSubview(self.itemKey)
        self.contentView.addSubview(self.itemValue);
        self.addLayoutConstrains()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(_ itemKeyName: String, itemValue: String?) {
        self.itemKey.text = itemKeyName;

        if (itemKeyName == "kFirstName".localized) {
            self.itemValue.tag = kInputFirstName;
            self.itemValue.delegate = delegate;
            if (delegate!.updateProfileView) {
                self.itemValue.text = AVUser.current()!.firstName!;
            }
        }

        if (itemKeyName == "kLastName".localized) {
            self.itemValue.tag = kInputLastName;
            self.itemValue.delegate = delegate;
            if (delegate!.updateProfileView) {
                self.itemValue.text = AVUser.current()!.lastName!;
            }
        }

        if (itemKeyName == "kCity".localized) {
            self.itemValue.tag = kInputLocation;
            self.itemValue.delegate = delegate;
            if (delegate!.updateProfileView) {
                self.itemValue.text = AVUser.current()!.city!;
            }
        }

        if (itemKeyName == "kIntro".localized) {
            self.itemValue.tag = kInputDescription;
            self.itemValue.delegate = delegate;
            if (delegate!.updateProfileView) {
                self.itemValue.text = AVUser.current()!.introduction!;
            }
        }

        if (itemKeyName == "kGender".localized) {
            let picker = UIPickerView();
            picker.tag = kPickerGender
            picker.delegate = delegate
            picker.dataSource = delegate
            delegate?.genderTextInput = self.itemValue;
            self.itemValue.inputView = picker;
            if (delegate!.updateProfileView) {
                self.itemValue.text = delegate!.genderOpt[AVUser.current()!.gender];
            }
        }

        if (itemKeyName == "kBirthday".localized) {
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.maximumDate = Date();
            delegate!.datePicker = picker;
            delegate!.dateTextInput = self.itemValue;
            self.itemValue.inputView = picker;
            picker.addTarget(delegate!, action: #selector(self.delegate!.updateDate), for: .valueChanged);
            if (delegate!.updateProfileView) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let dateString = dateFormatter.string(from: AVUser.current()!.birth!)
                self.itemValue.text = dateString;
            }
        }
        delegate!.validator.registerField(self.itemValue, rules: [RequiredRule(), MinLengthRule(length: 1)])
    }


    func selectToEdit() {
        self.itemValue.becomeFirstResponder();
    }

    private func addLayoutConstrains() {

        self.itemKey.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20);
            make.height.equalTo(16)
            make.width.equalTo(kScreenW / 3)
        }

        self.itemValue.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.itemKey);
            make.height.equalTo(16)
            make.right.equalToSuperview().offset(-10);
            make.left.equalTo(self.itemKey.snp.right).offset(5);
        }

        self.contentView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview();
            make.top.equalToSuperview();
            make.right.equalToSuperview();
            make.width.equalTo(kScreenW);
            make.bottom.equalTo(self.itemKey).offset(20);
        }
    }
}


class ProfileDetailButtonCell: UITableViewCell {

    private lazy var buttonText: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = fontMontserrat16
        label.textColor = CL_GREEN_DEFAULT;
        label.textAlignment = .center
        label.text = "kSave".localized
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.buttonText)
        self.buttonText.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(16)
            make.width.equalTo(kScreenW)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(_ text: String) {
        self.buttonText.text = text;
    }
}

