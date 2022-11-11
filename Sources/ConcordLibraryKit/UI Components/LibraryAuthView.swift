//
//  LibraryAuthView.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 27/7/2022.
//

import SwiftUI
import WebKit
import UIKit

struct LibraryAuthView: View {
    @Binding var didSucceed: Bool
    @State var isDone = false
    @State var cookie: String? = nil
    @State var showingAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        LibraryAuthView_WK(isDone: $isDone, cookie: $cookie)
            .onChange(of: cookie) { newValue in
                Library_APIManager.cookie = newValue
                if isDone {
                    self.presentationMode.wrappedValue.dismiss()
                    if cookie == "INVALID_APP" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showingAlert = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            didSucceed = true
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert("You must login with your school email", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
    }
}


fileprivate struct LibraryAuthView_WK: UIViewRepresentable {
    @Binding var isDone: Bool
    @Binding var cookie: String?
    
    func makeUIView(context: Context) -> WKWebView {
        let url = URL(string: Library_APIManager.mainURL + "/loginFromOpac")!
        var req = URLRequest(url: url)
        req.httpShouldHandleCookies = true
        let wkWebview = WKWebView()
        wkWebview.navigationDelegate = context.coordinator
        wkWebview.backgroundColor = .clear
        wkWebview.isOpaque = false
        wkWebview.load(req)
        return wkWebview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    // This has to be inside the representable structure
    class Coodinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: LibraryAuthView_WK
        var isDone: Binding<Bool>
        var cookie: Binding<String?>
        
        init(_ parent: LibraryAuthView_WK, isDone: Binding<Bool>, cookie: Binding<String?>) {
            self.parent = parent
            self.isDone = isDone
            self.cookie = cookie
        }
        
        // MARK: - Navigation Delegate
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
            
            if let url = navigationAction.request.url?.absoluteString, url == Library_APIManager.mainURL + "/library/search" {
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    if let sessionCookie = cookies.last(where: {
                        $0.name == "JSESSIONID"
                    }) {
                        let cookie = "JSESSIONID=" + sessionCookie.value + ";"
                        self.isDone.wrappedValue = true
                        self.cookie.wrappedValue = cookie
                    }
                }
            } else if let url = navigationAction.request.url?.absoluteString, url.contains("SAMLRequest") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    webView.evaluateJavaScript("document.body.innerText") { result, error in
                        if let resultString = result as? String,
                           resultString.contains("app_not_configured_for_user") {
                            DispatchQueue.main.async {
                                self.isDone.wrappedValue = true
                                self.cookie.wrappedValue = "INVALID_APP"
                                webView.configuration.websiteDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                                    webView.configuration.websiteDataStore.removeData(
                                        ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                        for: records/*.filter { $0.displayName.contains("facebook") }*/,
                                        completionHandler: {}
                                    )
                                }
                            }
                        }
                    }
                }
            }
            
            decisionHandler(.allow)
            
        }
        
    }
    
    func makeCoordinator() -> Coodinator {
        return Coodinator(self, isDone: self.$isDone, cookie: self.$cookie)
    }
    
}
