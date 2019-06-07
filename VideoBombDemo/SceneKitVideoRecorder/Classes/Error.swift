//
//  Error.swift
//
//

import UIKit

extension SceneKitVideoRecorder {
  public enum ErrorCode: Int {
    case notReady = 0
    case zeroFrames = 1
    case assetExport = 2
    case recorderBusy = 3
    case unknown = 4
  }
}

