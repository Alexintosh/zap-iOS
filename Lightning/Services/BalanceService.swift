//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

public final class BalanceService {
    private let api: LightningApiProtocol
    
    public let onChain = Observable<Satoshi>(0)
    let lightning = Observable<Satoshi>(0)
    public let total: Signal<Satoshi, NoError>

    init(api: LightningApiProtocol) {
        self.api = api
        total = combineLatest(onChain, lightning) { $0 + $1 }
    }
    
    func update() {
        api.walletBalance { [onChain] result in
            onChain.value = result.value ?? 0
        }
    
        api.channelBalance { [lightning] result in
            lightning.value = result.value ?? 0
        }
    }
}
