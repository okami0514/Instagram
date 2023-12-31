//
//  HomeViewController.swift
//  Instagram
//
//  Created by WEBSYSTEM-MAC29 on 2023/10/05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    let postData = PostData(document: document)
                    print("DEBUG_PRINT: \(postData)")
                    return postData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボ良いねタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleLikesButton(_:forEvent:)), for: .touchUpInside)
        
        // セル内のコメントボタンのアクションをソースコードで設定する
        cell.commentButton.addTarget(self, action:#selector(handleCommentsButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    // セル内の良いねボタンがタップされた時に呼ばれるメソッド
    @objc func handleLikesButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    // セル内のコメントボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentsButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: commentボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        var alertTextField: UITextField?
        
        let alert = UIAlertController(
            title: "コメント",
            message: "Enter comment",
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
                
            })
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default) { _ in
                    if let text = alertTextField?.text {
                        
                        print("DEBUG_PRINT: OKボタンがタップされました。")
                        if (text.isEmpty == false) {
                            // 文字が入力されていた場合commentsを更新する
                            if let myName = Auth.auth().currentUser?.displayName {
                                // 更新データを作成する
                                var updateValue: FieldValue
                                
                                updateValue = FieldValue.arrayUnion([myName + ":" + text])
                                // commentsに更新データを書き込む
                                let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                                postRef.updateData(["comments": updateValue])
                            }
                        }
                        
                    }
                }
        )
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
