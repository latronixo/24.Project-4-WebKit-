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
    var websites = [String]()
    var selectedWebsite: Int = 0
    
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
        let back = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(forwardTapped))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //создаем кнопку обновить
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))

        //создаем прогрессвью
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        //добавляем их в тулбар
        toolbarItems = [back, forward, progressButton, spacer, refresh]
        //делаем его видимым
        navigationController?.isToolbarHidden = false
        
        //добавляем наблюдателя для прогрессвью
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //загрузим адрес сайта
        let url = URL(string: "https://" + websites[selectedWebsite])!
        webView.load(URLRequest(url: url))
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
    
    @objc private func backTapped() {
        webView.goBack()
    }
    
    @objc private func forwardTapped() {
        webView.goForward()
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
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        //извлекаем host (не в каждом url есть host)
        if let host = url.host {
            //цикл по разрешенным вебсайтам
            for website in websites {
                //если host, на который переходит пользователь, входит в список разрешенных вебсайтов
                if host == website || host.hasSuffix("." + website) {
                    //то разрешаем переход
                    decisionHandler(.allow)
                    //и выходим из функции
                    return
                }
            }
        }
        
        //если же host, на который переходит пользователь, не входит в список разрешенных вебсайтов, то запрещаем этот переход
        decisionHandler(.cancel)
        
        //и сообщаем пользователю об этом (только если это не первоначальная загрузка
        if navigationAction.navigationType != .other {
            let ac = UIAlertController(title: "Ошибка", message: "переход на данный ресурс запрещен", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

