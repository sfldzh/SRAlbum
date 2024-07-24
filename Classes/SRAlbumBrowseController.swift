//
//  SRAlbumBrowseController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/22.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos

class SRAlbumBrowseController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var nvTop: NSLayoutConstraint!
    @IBOutlet weak var selectButton: SRAlbumSelect!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var zipButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var eidtButton: UIButton!
    @IBOutlet weak var zipConstraint: NSLayoutConstraint!
    
    weak var delegate:SRAlbumBrowseControllerDelegate?
    //TODO: 当前的相册组
    var collection:PHAssetCollection?
    var indexPath:IndexPath?
    var isScrollered:Bool = false;
    private var isCanEidt = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.configerView()
        _ = self.isCanSend()
        self.checkSelected()
        self.checkCanEidt()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isScrollered {
            isScrollered = true
            self.scrollToPage(indexPath: self.indexPath);
        }
    }
    
    //MARK: - 操作
    
    func initData() -> Void {
        if self.indexPath == nil {
            self.indexPath = IndexPath.init(row: 0, section: 0);
        }
    }
    
    /// TODO: 配置信息
    func configerView() -> Void {
        if #available(iOS 11, *) {
            self.nvTop.constant = SRHelper.getWindow()?.safeAreaInsets.top ?? 20
        }else{
            self.nvTop.constant = 20
        }
        self.isCanEidt = (is_eidt && max_count > 1)
        self.zipConstraint.priority =  self.isCanEidt ? .defaultHigh : .defaultLow//东西d改变压缩按钮的位置
        let layout = UICollectionViewFlowLayout();
        layout.scrollDirection = .horizontal;
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.showsVerticalScrollIndicator = false;
        self.collectionView.showsHorizontalScrollIndicator = false;
        self.collectionView.alwaysBounceHorizontal = true;
        self.collectionView.isPagingEnabled = true
        self.collectionView.register(UINib.init(nibName: "SRBrowseImageCell", bundle: bundle), forCellWithReuseIdentifier: "SRBrowseImageCell");
        self.zipButton.isSelected = !SRAlbumData.sharedInstance.isZip
    }
    
    /// TODO: 滑动到指定位置
    /// - Parameter indexPath: 指定位置
    func scrollToPage(indexPath:IndexPath?) -> Void {
        if indexPath != nil {
            DispatchQueue.main.async {
                if #available(iOS 14.0, *) {
                    let size = UIScreen.main.bounds.size
                    self.collectionView.scrollRectToVisible(CGRect.init(x: CGFloat(indexPath!.row) * size.width, y: 0, width: size.width, height: size.height), animated: false);
                }else{
                    self.collectionView.scrollToItem(at: indexPath!, at: .centeredHorizontally, animated: false)
                }
            }
        }
    }
    
    func checkSelected() -> Void {
        let asset = self.collection != nil ? self.collection!.assets[self.indexPath!.row] : SRAlbumData.sharedInstance.sList[self.indexPath!.row]
        let index = ((SRAlbumData.sharedInstance.sList.firstIndex(of: asset) ?? -1) + 1)
        self.selectButton.title = "\(index)"
        self.selectButton.isSelected = !(SRAlbumData.sharedInstance.sList.contains(asset))
    }
    
    func isCanSend() -> Bool{
        self.sendButton.isEnabled = SRAlbumData.sharedInstance.sList.count>0;
        return self.sendButton.isEnabled
    }
    
    func checkCanEidt() -> Void {
        let asset = self.collection != nil ? self.collection!.assets[self.indexPath!.row] : SRAlbumData.sharedInstance.sList[self.indexPath!.row]
        if asset.isPhoto() {
            self.eidtButton.isHidden = !self.isCanEidt
            self.zipButton.isHidden = false
        }else{
            self.zipButton.isHidden = true
            self.eidtButton.isHidden = true
        }
    }
    
    
    //MARK: - 点击事件
    @IBAction func dismissAction(_ sender: UIButton) {        
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func selectImageAction(_ sender: SRAlbumSelect) {
        if self.collection != nil {
            _ = self.delegate?.reloadAlbumData(data: self.collection!.assets[self.indexPath!.row], indexPath: self.indexPath!);
            self.checkSelected();
        }else{
            if SRAlbumData.sharedInstance.sList.count>1 {
                let isAdd = self.delegate?.reloadAlbumData(data: SRAlbumData.sharedInstance.sList[self.indexPath!.row], indexPath: nil) ?? false
                if !isAdd {
                    
                    self.collectionView.deleteItems(at: [self.indexPath!])
                    if SRAlbumData.sharedInstance.sList.count <= self.indexPath!.row {//容错，当删除最后一个时，索引要改变。
                        self.indexPath = IndexPath.init(row: SRAlbumData.sharedInstance.sList.count-1, section: 0);
                    }
                    self.checkSelected();
                }
            }else{
                _ = self.delegate?.reloadAlbumData(data: SRAlbumData.sharedInstance.sList[self.indexPath!.row], indexPath: nil) ?? false
                self.dismiss(animated: true) {
                }
            }
        }
        _ = self.isCanSend()
    }
    
    
    /// TODO: 发送
    /// - Parameter sender: 按钮
    @IBAction func sandAction(_ sender: UIButton) {
        self.delegate?.sendAsset();
    }
    
    /// TODO: 压缩
    /// - Parameter sender: 按钮
    @IBAction func zipAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        SRAlbumData.sharedInstance.isZip = !sender.isSelected
    }
    
    /// TODO: 编辑
    /// - Parameter sender: 按钮
    @IBAction func eidtAction(_ sender: Any) {
        let asset = self.collection != nil ? self.collection!.assets[self.indexPath!.row] : SRAlbumData.sharedInstance.sList[self.indexPath!.row]
        _ = asset.requestOriginalImage { [weak self] imageData, info in
            if let image = UIImage.init(data: imageData!) {
                let eidtAsset = EditorAsset.init(type: EditorAsset.AssetType.image(image), result: nil)
                var config: EditorConfiguration = .init()
                if !SRAlbumData.sharedInstance.eidtSize.equalTo(.zero){
                    config.cropSize.aspectRatio = SRAlbumData.sharedInstance.eidtSize
                    config.cropSize.isFixedRatio = true
                    config.cropSize.aspectRatios = []
                }
                config.toolsView.toolOptions.remove(at: 2)
                let vc = EditorViewController(eidtAsset, config: config)
                vc.modalPresentationStyle = .fullScreen
                vc.finishHandler = {[weak self] (eidtAsset, editorViewController) in
                    if eidtAsset.contentType == .image {
                        switch eidtAsset.type {
                        case .image(let image):
                            asset.editedPic = image
                            self?.collectionView.reloadData();
                            self?.delegate?.eidtFinish(data: asset)
                            break
                        default:
                            break
                        }
                    }
                }
//                vc.delegate = self
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK:- UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.view.bounds.size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collection?.assets.count ?? SRAlbumData.sharedInstance.sList.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data =  (self.collection != nil) ? self.collection!.assets[indexPath.row] : SRAlbumData.sharedInstance.sList[indexPath.row]
        let cell:SRBrowseImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SRBrowseImageCell", for: indexPath) as! SRBrowseImageCell;
        cell.data = data;
        return cell;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! SRBrowseImageCell).resetCell();
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        self.indexPath = IndexPath.init(row: page, section: 0)
        self.checkSelected()
        self.checkCanEidt()
    }
    
}

protocol SRAlbumBrowseControllerDelegate:NSObjectProtocol {
    
    /// TODO: 浏览器已经选择或者取消了资源
    /// - Parameters:
    ///   - data: 资源
    ///   - indexPath: 索引
    func reloadAlbumData(data:PHAsset, indexPath:IndexPath?) -> Bool
    
    /// TODO: 图片已经被编辑了
    /// - Parameters:
    ///   - data: 资源
    func eidtFinish(data:PHAsset) -> Void
    
    /// TODO:资源发送
    func sendAsset() -> Void
}
