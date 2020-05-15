//
//  GroupView.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit
import Photos

class GroupView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    var cancel:(()->())?
    var result:((PHAssetCollection) -> ())?
    
    
    var albumsCollection:Array<PHAssetCollection>?{
        didSet{
            self.tableView.reloadData();
        }
    }
    
    
    static func createGroupView() -> GroupView?{
        let datas = bundle!.loadNibNamed("GroupView", owner: nil, options: nil)!;
        var groupView:GroupView?
        for data in datas {
            let temp = data as! NSObject
            if temp.isKind(of: GroupView.classForCoder()){
                groupView = temp as? GroupView;
                groupView?.isHidden = true;
                groupView?.clipsToBounds = true;
                break
            }
        }
        return groupView;
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        self.configerView()
    }
    
    func configerView() -> Void {
        DispatchQueue.main.async {
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            self.tableView.estimatedRowHeight = 60;
            self.tableView.register(UINib.init(nibName: "SRAldumGroupTableViewCell", bundle: bundle), forCellReuseIdentifier: "SRAldumGroupTableViewCell")
        }
    }
    
    @IBAction func didClickBack(_ sender: UITapGestureRecognizer) {
        self.cancel?();
        self.hiddenView();
    }
    
    func show(result:@escaping ((PHAssetCollection) -> ()), cancel:@escaping (()->())) -> Void {
        self.result = result;
        self.cancel = cancel;
        self.isHidden = false;
        self.backView.alpha = 0.0;
        UIView.animate(withDuration: 0.3, animations: {
            self.backView.alpha = 1.0;
            self.contentConstraint.priority = .defaultLow;
            self.layoutIfNeeded();
        }) { (sucess) in
            
        }
    }
    
    func hiddenView() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.backView.alpha = 0.0;
            self.contentConstraint.priority = .defaultHigh;
            self.layoutIfNeeded();
        }) { (sucess) in
            self.isHidden = true;
        }
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews();
        self.contentHeight.constant = self.bounds.height-120;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.estimatedRowHeight;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumsCollection?.count ?? 0;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SRAldumGroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SRAldumGroupTableViewCell", for: indexPath) as! SRAldumGroupTableViewCell;
        cell.selectionStyle = .none;
        cell.data = self.albumsCollection![indexPath.row];
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.result?(self.albumsCollection![indexPath.row])
        self.hiddenView();
    }
}
