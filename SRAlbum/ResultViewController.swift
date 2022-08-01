//
//  ResultViewController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/2/21.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var images:Array<UIImage>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configerView()
    }
    
    func configerView() -> Void {
        self.tableView.register(UINib.init(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "ShowTableViewCell");
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = images?[indexPath.row]
        var height:CGFloat = 0
        if image!.size.width > Appsize().width {
            height = image!.size.height * (Appsize().width/image!.size.width)
        }else{
            height = image!.size.height
        }
        return height
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ShowTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ShowTableViewCell", for: indexPath) as! ShowTableViewCell
        cell.showImage = images?[indexPath.row]
        return cell
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
