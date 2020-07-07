//
//  ContentView.swift
//  Shared
//
//  Created by Noah Rubin on 7/7/20.
//

import SwiftUI
import Combine
import OneTimePassword

#if canImport(CodeScanner)
import CodeScanner
#endif

let sampleOtpAuth = "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30";

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(entity: Account.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Account.otpauth, ascending: true)]) var accounts: FetchedResults<Account>
    
    @State private var isShowingScanner = false
    @State private var dateTime = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(accounts) { account in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(account.token.issuer)
                                    .font(.title2)
                                Text(account.token.name)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Text(try! account.token.generator.password(at: dateTime))
                                .font(.title)
                        }
//                        .foregroundColor(account.accentColor)
                    }.onDelete { indexSet in
                        indexSet.forEach { index in
                            self.context.delete(accounts[index])
                        }
                        
                        try! self.context.save()
                    }
                }
                .navigationBarTitle("Accounts")
                .navigationBarItems(trailing: Button(action: {
                    self.isShowingScanner = true
                }, label: {
                    Image(systemName: "plus.circle.fill")
                }))
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: sampleOtpAuth, completion: self.handleScan)
                }
            }
            .onReceive(MyTimer().currentTimePublisher) { dateTime in self.dateTime = dateTime }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        
        switch (result) {
            case .success(let url): do {
                if let otpauth = URL(string: url), let _ = Token(url: otpauth) {
                    let account = Account(context: context)
                    account.otpauth = otpauth
                    account.accentColorString = UIColor.blue.cgColor.components!.map { "\($0)" }.joined(separator: " ")
                    try! context.save()
                }
            }
            case .failure(let error):
                print(error)
        }
    }
}

class MyTimer {
    let currentTimePublisher = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)
    let cancellable: AnyCancellable?
    
    init() {
        self.cancellable = currentTimePublisher.connect() as? AnyCancellable
    }
    
    deinit {
        self.cancellable?.cancel()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
