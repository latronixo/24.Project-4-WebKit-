//
//  ViewController.swift
//  23.Project-4-FlagsInTableView
//
//  Created by Валентин Картошкин on 30.04.2025.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    
    //список разрешенных вебсайтов, по которым пользователь может переходить в нашем приложении
    var websites = ["apple.com", "hackingwithswift.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //создадим кнопку в навигейшнконтроллере
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        //создаем тулбар (встроен в навигейшнконтроллер)
        //создаем пустое пространство, занимающее столько места, сколько он может, притесняя остальные элементы внутри его контейнера
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //создаем кнопку обновить
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))

        //создаем прогрессвью
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        //добавляем их в тулбар
        toolbarItems = [progressButton, spacer, refresh]
        //делаем его видимым
        navigationController?.isToolbarHidden = false
        
        //добавляем наблюдателя для прогрессвью
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        //загрузим адрес сайта
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    private func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https://" + actionTitle) else { return }
        webView.load(URLRequest(url: url))
    }
    
    //событие завершения перехода на веб-страницу
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
           progressView.progress = Float(webView.estimatedProgress)
       }
    }
    
    //событие перехода на новую страницу внутри webView (разрешено переходить только по заданному списку сайтов)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        //для удобства получаем url в отдельной константе
        let url = navigationAction.request.url
        
        //извлекаем host (не в каждом url есть host)
        if let host = url?.host {
            //цикл по разрешенным вебсайтам
            for website in websites {
                //если host, на который переходит пользователь, входит в список разрешенных вебсайтов
                if host.contains(website) {
                    //то разрашаем переход
                    decisionHandler(.allow)
                    //и выходим из функции
                    return
                }
            }
        }
        
        //если же host, на который переходит пользователь не входит в список разрешенных вебсайтов, то запрещаем этот переход
        decisionHandler(.cancel)
    }
}

