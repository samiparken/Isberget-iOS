//
//  ResetPasswordManager.swift
//  InstallationsPartner-iOS
//
//  Created by Sam on 12/14/20.
//

import Foundation

struct ResetPasswordManager {
    func requestReset(with email: String) {
        APIresetPassword(email: email); semaphore.wait()
    }
}
