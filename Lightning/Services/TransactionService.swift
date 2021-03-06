//
//  Zap
//
//  Created by Otto Suess on 09.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

public final class TransactionService {
    private let api: LightningApiProtocol
    private let balanceService: BalanceService
    private let channelService: ChannelService
    
    private let unconfirmedTransactionStore = UnconfirmedTransactionStore()
    
    public let transactions = Observable<[Transaction]>([])
    
    init(api: LightningApiProtocol, balanceService: BalanceService, channelService: ChannelService) {
        self.api = api
        self.balanceService = balanceService
        self.channelService = channelService
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<OnChainUnconfirmedTransaction>) -> Void) {
        api.sendCoins(address: address, amount: amount) { [weak self] in
            if let newTransaction = $0.value {
                self?.unconfirmedTransactionStore.add(newTransaction)
                self?.transactions.value.append(newTransaction)
            }
            completion($0)
        }
    }
    
    public func addInvoice(amount: Satoshi, memo: String?, completion: @escaping (Result<String>) -> Void) {
        api.addInvoice(amount: amount, memo: memo) { [weak self] in
            if $0.value != nil {
                self?.update()
            }
            completion($0)
        }
    }
    
    public func newAddress(with type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        api.newAddress(type: type, completion: completion)
    }
    
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, completion: completion)
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping (Result<Data>) -> Void) {
        api.sendPayment(paymentRequest, amount: amount) { [weak self] result in
            if result.value != nil {
                self?.update()
                self?.balanceService.update()
                self?.channelService.update()
            }
            completion(result)
        }
    }
    
    public func update() {
        let taskGroup = DispatchGroup()

        var allTransactions = [Transaction]()
        
        func apiCallback(result: Result<[Transaction]>) {
            if let transactions = result.value {
                allTransactions.append(contentsOf: transactions)
            }
            taskGroup.leave()
        }
        
        taskGroup.enter()
        api.transactions(completion: apiCallback)

        taskGroup.enter()
        api.payments(completion: apiCallback)
        
        taskGroup.enter()
        api.invoices(completion: apiCallback)
        
        taskGroup.notify(queue: .main, work: DispatchWorkItem(block: { [weak self] in
            self?.unconfirmedTransactionStore.remove(confirmed: allTransactions)
            if let unconfirmed = self?.unconfirmedTransactionStore.all {
                allTransactions.append(contentsOf: unconfirmed)
            }
            self?.transactions.value = allTransactions
        }))
    }
}
