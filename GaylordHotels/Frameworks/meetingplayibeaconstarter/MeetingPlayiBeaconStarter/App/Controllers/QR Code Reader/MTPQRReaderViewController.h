//
//  MTPQRReaderViewController.h
//  MeetingPlay
//
//  Created by Michael Thongvanh on 2/20/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPBaseViewController.h"

@class AVCaptureSession, AVCaptureVideoPreviewLayer, AVCaptureMetadataOutput;

@interface MTPQRReaderViewController : MTPBaseViewController

@property (nonatomic, strong) AVCaptureSession *qrCaptureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadata;
@property (nonatomic, assign, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic, strong) UIView *previewLayerContainer;

@property (nonatomic, strong) UIButton *beginScanButton;

- (void)startSession;
- (void)stopSession;

@end
