//
//  CollageView.swift
//  loop
//
//  Created by Yecol Hsu on 31/12/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import MWPhotoBrowser

private let _ratio: CGFloat = 0.7;
private let _spacing: CGFloat = 2;
private let _height2: CGFloat = (kScreenW - _spacing) / 2;
private let _height3: CGFloat = (kScreenW - _spacing) / 2 * 0.6;
private let _height4: CGFloat = (kScreenW - _spacing * 2) / 3;

let kCollageHeight1: CGFloat = kScreenW * _ratio;
let kCollageHeight2: CGFloat = _height2 * 2;
let kCollageHeight3: CGFloat = kScreenW * _ratio + _height3 + _spacing;
let kCollageHeightMore: CGFloat = kScreenW * _ratio + _height4 + _spacing;


class CollageView: UIView, MWPhotoBrowserDelegate {

    public func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        if (Int(index) < mwphotos.count) {
            return mwphotos.object(at: Int(index)) as! MWPhoto;
        } else {
            return nil;
        }
    }

    public func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(mwphotos.count);
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var bigPhotoView: UIImageView?

    var dblPhotoView1: UIImageView?
    var dblPhotoView2: UIImageView?

    var morePhotoView1: UIImageView?
    var morePhotoView2: UIImageView?
    var morePhotoView3: UIImageView?

    var mwphotos = NSMutableArray();

    var size = 0;

    func calculateHeight() -> CGFloat {
        switch size {
        case 0: return 0;
        case 1: return kCollageHeight1;
        case 2: return kCollageHeight2;
        case 3: return kCollageHeight3;
        default: return kCollageHeightMore;
        }
    }

    static func calculateHeight(post: LPPost) -> CGFloat {
        if (post.imageList == nil) {
            return 0;
        } else {
            switch post.imageList!.count {
            case 0: return 0;
            case 1: return kCollageHeight1;
            case 2: return kCollageHeight2;
            case 3: return kCollageHeight3;
            default: return kCollageHeightMore;
            }
        }
    }

    func clean() {
        for v in self.subviews {
            v.removeFromSuperview();
        }

        bigPhotoView = nil
        dblPhotoView1 = nil
        dblPhotoView2 = nil

        morePhotoView1 = nil
        morePhotoView2 = nil
        morePhotoView3 = nil

        mwphotos.removeAllObjects();

        size = 0;
    }


    func setPhotosAVFile(_ photos: NSArray?) {
        //UIImage array
        if (size != 0) {
            clean();
        }

        if (photos == nil) {
            return;
        }

        size = photos!.count;
        self.backgroundColor = UIColor.white;

        for avfile in photos as! [AVFile] {
            let mwphoto = MWPhoto.init(url: URL.init(string: avfile.url!))!;
            mwphotos.add(mwphoto);
        }

        if (size == 1) {
            bigPhotoView = UIImageView.init();
            bigPhotoView!.sd_setImage(with: URL.init(string: (photos![0] as! AVFile).url!));
            bigPhotoView!.contentMode = .scaleAspectFill;
            bigPhotoView!.clipsToBounds = true;
            bigPhotoView!.tag = 0
            self.addSubview(bigPhotoView!);
        } else if (size == 2) {
            dblPhotoView1 = UIImageView.init();
            dblPhotoView1!.sd_setImage(with: URL.init(string: (photos![0] as! AVFile).url!));
            dblPhotoView1!.contentMode = .scaleAspectFill;
            dblPhotoView1!.clipsToBounds = true;
            dblPhotoView1!.tag = 0;
            self.addSubview(dblPhotoView1!);

            dblPhotoView2 = UIImageView.init();
            dblPhotoView2!.sd_setImage(with: URL.init(string: (photos![1] as! AVFile).url!));
            dblPhotoView2!.contentMode = .scaleAspectFill;
            dblPhotoView2!.clipsToBounds = true;
            dblPhotoView2!.tag = 1;
            self.addSubview(dblPhotoView2!)
        } else if (size >= 3) {
            bigPhotoView = UIImageView.init();
            bigPhotoView!.sd_setImage(with: URL.init(string: (photos![0] as! AVFile).url!));
            bigPhotoView!.contentMode = .scaleAspectFill;
            bigPhotoView!.clipsToBounds = true;
            bigPhotoView!.tag = 0;
            self.addSubview(bigPhotoView!);

            morePhotoView1 = UIImageView.init();
            morePhotoView1!.sd_setImage(with: URL.init(string: (photos![1] as! AVFile).url!));
            morePhotoView1!.contentMode = .scaleAspectFill;
            morePhotoView1!.clipsToBounds = true;
            morePhotoView1!.tag = 1;
            self.addSubview(morePhotoView1!);

            morePhotoView2 = UIImageView.init();
            morePhotoView2!.sd_setImage(with: URL.init(string: (photos![2] as! AVFile).url!));
            morePhotoView2!.contentMode = .scaleAspectFill;
            morePhotoView2!.clipsToBounds = true;
            morePhotoView2!.tag = 2;
            self.addSubview(morePhotoView2!)

            if (size >= 4) {
                morePhotoView3 = UIImageView.init();
                morePhotoView3!.sd_setImage(with: URL.init(string: (photos![3] as! AVFile).url!));
                morePhotoView3!.contentMode = .scaleAspectFill;
                morePhotoView3!.clipsToBounds = true;
                morePhotoView3!.tag = 3;
                self.addSubview(morePhotoView3!)
            }
        }
        
        self.addLayoutConstraints();
    }


    func setPhotos(_ photos: NSArray) {
        //UIImage array
        if (size != 0) {
            clean();
        }
        size = photos.count;


        if (size == 1) {
            bigPhotoView = UIImageView.init(image: (photos[0] as! UIImage));
            bigPhotoView!.contentMode = .scaleAspectFill;
            bigPhotoView!.clipsToBounds = true;
            self.addSubview(bigPhotoView!);
        } else if (size == 2) {
            dblPhotoView1 = UIImageView.init(image: (photos[0] as! UIImage));
            dblPhotoView1!.contentMode = .scaleAspectFill;
            dblPhotoView1!.clipsToBounds = true;
            self.addSubview(dblPhotoView1!);

            dblPhotoView2 = UIImageView.init(image: (photos[1] as! UIImage));
            dblPhotoView2!.contentMode = .scaleAspectFill;
            dblPhotoView2!.clipsToBounds = true;
            self.addSubview(dblPhotoView2!)
        } else if (size >= 3) {
            bigPhotoView = UIImageView.init(image: (photos[0] as! UIImage));
            bigPhotoView!.contentMode = .scaleAspectFill;
            bigPhotoView!.clipsToBounds = true;
            self.addSubview(bigPhotoView!);

            morePhotoView1 = UIImageView.init(image: (photos[1] as! UIImage));
            morePhotoView1!.contentMode = .scaleAspectFill;
            morePhotoView1!.clipsToBounds = true;
            self.addSubview(morePhotoView1!);

            morePhotoView2 = UIImageView.init(image: (photos[2] as! UIImage));
            morePhotoView2!.contentMode = .scaleAspectFill;
            morePhotoView2!.clipsToBounds = true;
            self.addSubview(morePhotoView2!)

            if (size >= 4) {
                morePhotoView3 = UIImageView.init(image: (photos[3] as! UIImage));
                morePhotoView3!.contentMode = .scaleAspectFill;
                morePhotoView3!.clipsToBounds = true;
                self.addSubview(morePhotoView3!)
            }
        }
        self.addLayoutConstraints();

    }

//
//    override func layoutSubviews() {
//        super.layoutSubviews();
//
//        self.backgroundColor = UIColor.white;
//
//        if (self.bigPhotoView != nil) {
//            self.bigPhotoView!.snp.makeConstraints { (make) -> Void in
//                make.width.equalTo(kScreenW);
//                make.height.equalTo(kCollageHeight1);
//                make.top.equalToSuperview();
//                make.left.equalToSuperview();
//            }
//        }
//
//        if (dblPhotoView1 != nil && dblPhotoView2 != nil) {
//            self.dblPhotoView1!.snp.makeConstraints { (make) -> Void in
//                make.width.equalTo(kScreenW);
//                make.height.equalTo(kScreenW / 2);
//                make.top.equalToSuperview();
//                make.left.equalToSuperview();
//            }
//
//            self.dblPhotoView2!.snp.makeConstraints { (make) -> Void in
//                make.size.equalTo(self.dblPhotoView1!);
//                make.top.equalTo(self.dblPhotoView1!.snp.bottom).offset(_spacing)
//                make.left.equalToSuperview();
//            }
//        }
//
//
//        if (morePhotoView1 != nil && morePhotoView2 != nil) {
//            if (morePhotoView3 == nil) {
//
//                self.morePhotoView1!.snp.makeConstraints { (make) -> Void in
//                    make.width.equalTo(kScreenW / 2 - 1);
//                    make.height.equalTo(_height3);
//                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
//                    make.left.equalTo(self.bigPhotoView!.snp.left);
//                }
//
//                self.morePhotoView2!.snp.makeConstraints { (make) -> Void in
//                    make.size.equalTo(self.morePhotoView1!);
//                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
//                    make.right.equalTo(self.bigPhotoView!.snp.right);
//                }
//            } else {
//
//                self.morePhotoView1!.snp.makeConstraints { (make) -> Void in
//                    make.width.equalTo(_height4);
//                    make.height.equalTo(_height4);
//                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
//                    make.left.equalTo(self.bigPhotoView!.snp.left);
//                }
//
//                self.morePhotoView2!.snp.makeConstraints { (make) -> Void in
//                    make.size.equalTo(self.morePhotoView1!);
//                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
//                    make.centerX.equalTo(self.bigPhotoView!.snp.centerX);
//                }
//
//                self.morePhotoView3!.snp.makeConstraints { (make) -> Void in
//                    make.size.equalTo(self.morePhotoView1!);
//                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
//                    make.right.equalTo(self.bigPhotoView!.snp.right);
//                }
//            }
//        }
//    }

    private func addLayoutConstraints() {

        // two photos
        if (dblPhotoView1 != nil && dblPhotoView2 != nil) {

            self.dblPhotoView1!.snp.makeConstraints { (make) -> Void in
                make.width.equalTo(kScreenW);
                make.height.equalTo(kScreenW / 2);
                make.top.equalToSuperview();
                make.left.equalToSuperview();
            }

            self.dblPhotoView2!.snp.makeConstraints { (make) -> Void in
                make.size.equalTo(self.dblPhotoView1!);
                make.top.equalTo(self.dblPhotoView1!.snp.bottom).offset(_spacing)
                make.left.equalToSuperview();
            }

//            self.snp.makeConstraints { (make) -> Void in
//                make.width.equalTo(kScreenW);
//                make.bottom.equalTo(self.dblPhotoView2!);
//            }

            return;
        }


        if (self.bigPhotoView != nil) {
            self.bigPhotoView!.snp.makeConstraints { (make) -> Void in
                make.width.equalTo(kScreenW);
                make.height.equalTo(kCollageHeight1);
                make.top.equalToSuperview();
                make.left.equalToSuperview();
            }
        }

        if (morePhotoView1 != nil && morePhotoView2 != nil) {

            if (morePhotoView3 == nil) {
                // --------------
                // |            |
                // |            |
                // --------------
                // |     |      |
                // --------------
                self.morePhotoView1!.snp.makeConstraints { (make) -> Void in
                    make.width.equalTo(kScreenW / 2 - 1);
                    make.height.equalTo(_height3);
                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
                    make.left.equalTo(self.bigPhotoView!.snp.left);
                }

                self.morePhotoView2!.snp.makeConstraints { (make) -> Void in
                    make.size.equalTo(self.morePhotoView1!);
                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
                    make.right.equalTo(self.bigPhotoView!.snp.right);
                }

//                self.snp.makeConstraints { (make) -> Void in
//                    make.width.equalTo(kScreenW);
//                    make.bottom.equalTo(self.morePhotoView2!);
//                }
                return;

            } else {

                // --------------
                // |            |
                // |            |
                // --------------
                // |   |    |   |
                // --------------

                self.morePhotoView1!.snp.makeConstraints { (make) -> Void in
                    make.width.equalTo(_height4);
                    make.height.equalTo(_height4);
                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
                    make.left.equalTo(self.bigPhotoView!.snp.left);
                }

                self.morePhotoView2!.snp.makeConstraints { (make) -> Void in
                    make.size.equalTo(self.morePhotoView1!);
                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
                    make.centerX.equalTo(self.bigPhotoView!.snp.centerX);
                }

                self.morePhotoView3!.snp.makeConstraints { (make) -> Void in
                    make.size.equalTo(self.morePhotoView1!);
                    make.top.equalTo(self.bigPhotoView!.snp.bottom).offset(_spacing);
                    make.right.equalTo(self.bigPhotoView!.snp.right);
                }

//                self.snp.makeConstraints { (make) -> Void in
//                    make.width.equalTo(kScreenW);
//                    make.bottom.equalTo(self.morePhotoView3!);
//                }
                return;
            }
        }
        else{
            // --------------
            // |            |
            // |            |
            // --------------
//            self.snp.makeConstraints { (make) -> Void in
//                make.width.equalTo(kScreenW);
//                make.bottom.equalTo(self.bigPhotoView!);
//            }
            return;
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            for imageview in self.subviews {
                if (imageview.frame.contains(point)) {
                    self.presentPhotoPicker(index: imageview.tag);
                }
            }
        }
    }


    func presentPhotoPicker(index: Int) {

        let browser = MWPhotoBrowser.init(delegate: self)!
        browser.displayActionButton = false;
        browser.displayNavArrows = false;
        browser.displaySelectionButtons = false;
        browser.alwaysShowControls = false;
        browser.zoomPhotosToFill = true;
        browser.enableGrid = false;
        browser.startOnGrid = false;
        browser.autoPlayOnAppear = false;
        browser.setCurrentPhotoIndex(UInt(index));
        browser.enableSwipeToDismiss = true;

        let nc = UINavigationController.init(rootViewController: browser);
        browser.modalTransitionStyle = .crossDissolve
        self.viewController()!.present(nc, animated: true, completion: nil);
    }


}
