//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum RPCConnectQRCodeError: Error {
    case btcPayExpired
    case btcPayConfigurationBroken
    case cantReadQRCode
}

/// Decodes RPCConfiguration from both BTCPay & zapconnect QRCodes
public enum RPCConnectQRCode {
    public static func configuration(for string: String, completion: @escaping (Result<RemoteRPCConfiguration>) -> Void) {
        if let qrCode = ZapconnectQRCode(json: string) {
            completion(.success(qrCode.rpcConfiguration))
        } else if let btcPayQRCode = BTCPayQRCode(string: string) {
            btcPayQRCode.fetchConfiguration { result in
                let mappedResult = result.flatMap { configData -> Result<RemoteRPCConfiguration> in
                    if let configuration = BTCPayConfiguration(data: configData)?.rpcConfiguration {
                        return .success(configuration)
                    } else {
                        return .failure(RPCConnectQRCodeError.btcPayConfigurationBroken)
                    }
                }
                completion(mappedResult)
            }
        } else {
            completion(.failure(RPCConnectQRCodeError.cantReadQRCode))
        }
    }
}
