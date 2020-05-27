//
//  MUQrCodeController.swift
//  MUSwiftFramework
//
//  Created by Ilya B Macmini on 02/08/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - MUQrCodeController

class MUQrCodeController: MUViewController {
    
    // MARK: - Override properties
    
    override class var storyboardName: String { return "MUQrCode" }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    
    // MARK: - Public properties
    
    var completionBlock: ((String?) -> Void)?
    
    var descriptionText: String?
    
    // MARK: - Private properties
    
    @IBOutlet private weak var videoView: UIView!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var captureSession: AVCaptureSession!
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        descriptionLabel.text = descriptionText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false { captureSession.startRunning() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true { captureSession.stopRunning() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        requestAccessForCamera { [weak self] success in
            
            if success {
                
                self?.setupCamera()
                
            } else {
                
                self?.showSettingsPopup()
            }
        }
    }
    
    // MARK: - Private methods
    
    @IBAction private func closeButtonTouched(_ sender: UIButton) {
        
        closeAndReturnResult(nil)
    }
    
    private func requestAccessForCamera(completion: @escaping (Bool) -> Void) {
        
        if (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized) {
            
            DispatchQueue.main.async { completion(true) }
            
        } else {
            
            AVCaptureDevice.requestAccess(for: .video) { result in
                
                DispatchQueue.main.async { completion(result) }
            }
        }
    }
    
    private func goToSettings() {
        
        guard
            
            let url = URL(string: UIApplication.openSettingsURLString),
            
            UIApplication.shared.canOpenURL(url)
            
        else {
            
            return
        }
        
        if #available(iOS 10.0, *) {
            
            UIApplication.shared.open(url)
            
        } else {
            
            UIApplication.shared.openURL(url)
        }
    }
    
    private func showSettingsPopup() {
        
        showDialogAlert(
            
            title             : "Access to Camera is denied".localize,
            message           : "Please allow the app to use Camera in Settings".localize,
            leftButtonTitle   : "Cancel".localize,
            rightButtonTitle  : "OK".localize,
            leftButtonStyle   : .cancel,
            rightButtonStyle  : .default,
            leftButtonAction  : { self.closeAndReturnResult(nil) },
            rightButtonAction : { self.goToSettings() }
        )
    }
    
    private func setupCamera() {
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        } catch {
            
            Log.error("error: failed to setup camera")
            
            return
        }
        
        guard captureSession.canAddInput(videoInput) == true else {
            
            Log.error("error: failed to setup camera")
                
            return
        }
            
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard captureSession.canAddOutput(metadataOutput) == true else {
            
            Log.error("error: failed to setup camera")
            
            return
        }
        
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = videoView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        videoView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    private func closeAndReturnResult(_ result: String? = nil) {
        
        close(animated: true) { [weak self] () in
            
            self?.completionBlock?(result)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension MUQrCodeController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(
        
        _ output                  : AVCaptureMetadataOutput,
        didOutput metadataObjects : [AVMetadataObject],
        from connection           : AVCaptureConnection
    ) {
        
        captureSession.stopRunning()
        
        var outputString: String?
        
        if
            
          let metadataObject = metadataObjects.first,
          let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
            
          outputString = readableObject.stringValue
        }
        
        closeAndReturnResult(outputString)
    }
}
