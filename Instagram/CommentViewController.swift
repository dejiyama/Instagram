//
//  CommentViewController.swift
//  Instagram
//
//  Created by 出島大和 on 2018/01/29.
//  Copyright © 2018年 出島大和. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class CommentViewController: UIViewController {
    @IBOutlet weak var CommentText: UITextField!
    
    //受け取るためのプロパティを用意しておく
    //postDataは受け取った。
    var postData: PostData!
    
    //投稿ボタンが押された時の処理
    @IBAction func CommentButton(_ sender: UIButton) {
        
        //commentDataに必要な情報を取得しておく
        let time = Date.timeIntervalSinceReferenceDate
        let name = Auth.auth().currentUser?.displayName
        
        //辞書を作成してfirebaseに保存する
        let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!).child(Const.CommentPath)
        let comment = ["comment": CommentText.text!, "time": String(time), "name": name!]
        
        //保存する
        postRef.childByAutoId().setValue(comment)
        
        
        // HUDでコメント完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました。")
        
        //全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    //キャンセルボタンが押されたときに処理
    @IBAction func CommentCancelButton(_ sender: AnyObject) {
        //画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
