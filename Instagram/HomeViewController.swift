//
//  HomeViewController.swift
//  Instagram
//
//  Created by 出島大和 on 2018/01/26.
//  Copyright © 2018年 出島大和. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postArray: [PostData] = []
    
    var postData: PostData!
    
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        //セル内のコメントボタンのアクションをソースことで設定する。
        cell.Comment.addTarget(self, action:#selector(commentHandleButton(_:forEvent:)),
                               for: .touchUpInside)
        
        return cell
    }
    //コメント関連の記述
    @objc func commentHandleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメントボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = postArray[indexPath!.row]
        
        self.postData = postData
        self.performSegue(withIdentifier: "toCommentViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segueから遷移先のcommentleviewcontroller.swiftを取得する
        let commentViewController:CommentViewController = segue.destination as! CommentViewController
        commentViewController.postData = self.postData
        
    }
    
    //セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid{
            if postData.isLiked {
                //すでにいいねしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        //削除するためにインデックスを保存しておく
                        index = postData.likes.index(of: likeId)!
                        break
                        
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            
            //増えたLikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
    }
    
    //先ずはviewDidLoad()メソッドでUITableViewの準備とFirebaseからデータを取り出す。
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //テーブル行の高さをAoutLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        //テーブル行の高さの概算値を設定しておく
        //高さ概算値＝「縦横比１：１のUIImageViewの高さ（＝画面幅）」＋「いいね!ボタン、キャンプラベル、その他余白の高さ」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                //要素が追加されたらpostArrayに追加してtableviewを再表示する
                let postRef = Database.database().reference().child(Const.PostPath)
                postRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    //PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                //要素が変更されたら当該のデータをpostArrayカラチ井戸削除した後に新しいデータを追加してTableViewを再表示する
                postRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        //PostDataクラスを作成して受け取ったデータを赤って委する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        //保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        //差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        //削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                //DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        }else {
            if observing == true {
                //ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する
                //テーブルをクリアする
                postArray = []
                tableView.reloadData()
                //オブザーブを削除する
                Database.database().reference().removeAllObservers()
                
                //DatabaseのobserveEventが上記コードにより解除されたため
                //falseとする
                observing = false
            }
        }
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
