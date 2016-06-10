//
//  MTPQRReaderViewController.m
//  MercedesBenz
//
//  Created by Michael Thongvanh on 2/20/15.
//  Copyright (c) 2015 Chisel Apps. All rights reserved.
//

#import "MTPQRReaderViewController.h"
#import <AVFoundation/AVFoundation.h> 
#import "SIAlertView.h"
#import "NSObject+EventDefaultsHelpers.h"

@interface MTPQRReaderViewController () <AVCaptureMetadataOutputObjectsDelegate>
@end

@implementation MTPQRReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.previewLayerContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:self.previewLayerContainer atIndex:0];
    
    [self setupQRScanner];
    [self registerForNotifications];
    
    [self configureScanButton];
    self.beginScanButton.translatesAutoresizingMaskIntoConstraints = false;

    [self startSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupButtonConstraints];
    
    if (self.isSessionRunning == false) {
        self.beginScanButton.enabled = true;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopSession];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma NSNotification Registration

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

#pragma mark QR Setup

- (void)setupQRScanner {
    if (self.qrCaptureSession) {
        return;
    }
    
    self.qrCaptureSession = [[AVCaptureSession alloc] init];
    self.qrCaptureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureDeviceInput *cameraBackFacing;
    NSArray *possibleCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (!possibleCaptureDevices) {
        SIAlertView *noCameraAlert = [[SIAlertView alloc] initWithTitle:@"No Camera Found!"
                                                             andMessage:@"We couldn't access your camera in order to scan the QR Code"];
        [noCameraAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [noCameraAlert show];
        return;
    }
    
    for (AVCaptureDevice *device in possibleCaptureDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            NSError *deviceInputSettingError = nil;
            cameraBackFacing = [AVCaptureDeviceInput deviceInputWithDevice:device error:&deviceInputSettingError];
            
            if (!cameraBackFacing || deviceInputSettingError) {
                DLog(@"\nCamera error %@", deviceInputSettingError.localizedDescription);
            }
        }
    }
    
    if ([self.qrCaptureSession canAddInput:cameraBackFacing]) {
        [self.qrCaptureSession addInput:cameraBackFacing];
    } else {
        DLog(@"\ncant add the camera to the session");
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.qrCaptureSession];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewLayerContainer.layer addSublayer:self.previewLayer];
    
    self.captureMetadata = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataCaptureQueue = dispatch_queue_create("com.MeetingPlay.QRCodeReader", 0);
    [self.captureMetadata setMetadataObjectsDelegate:self queue:metadataCaptureQueue];
    
    if ([self.qrCaptureSession canAddOutput:self.captureMetadata]) {
        [self.qrCaptureSession addOutput:self.captureMetadata];
    } else {
        DLog(@"\ncan't add metadata output");
    }
}

#pragma mark Starting and Stopping QR Session

- (void)startSession {
    if (self.isSessionRunning) {
        return;
    } else {
        self.sessionRunning = true;
        self.beginScanButton.enabled = false;
    }
    
    [self.qrCaptureSession startRunning];
    self.captureMetadata.metadataObjectTypes = self.captureMetadata.availableMetadataObjectTypes;
//    self.previewLayer.hidden = false;
//    DLog(@"%@", self.isSessionRunning ? @"true" : @"false");
}

- (void)stopSession {
    if (self.isSessionRunning == false) {
        return;
    }
    
    [self.qrCaptureSession stopRunning];
    self.sessionRunning = false;
    self.beginScanButton.enabled = true;
//    self.previewLayer.hidden = true;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate Conformance

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadataObject in metadataObjects)
    {
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            if ([codeObject.type isEqualToString:@"org.iso.QRCode"])
            {
                [self showQRFound:codeObject];
            }
        }
    }
}

- (void)showQRFound:(AVMetadataMachineReadableCodeObject *)codeObject {
    SIAlertView *foundBeaconAlert = [[SIAlertView alloc] initWithTitle:@"Found a QR Code" andMessage:@"You've discovered a QR Code.\nWould you like to view the link?"];
    [foundBeaconAlert addButtonWithTitle:@"View Link" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        if ([codeObject.stringValue rangeOfString:@"http://"].location != NSNotFound ||
            [codeObject.stringValue rangeOfString:@"https://"].location != NSNotFound)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:codeObject.stringValue]];
        }
    }];
    [foundBeaconAlert addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDefault handler:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopSession];
        [foundBeaconAlert show];
    });
}

- (void)configureScanButton {
    self.beginScanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beginScanButton.layer.cornerRadius = 3.f;
    self.beginScanButton.layer.masksToBounds = true;
    
    [[self.beginScanButton titleLabel] setFont:[UIFont fontWithName:@"Roboto" size:19.f]];
    
//    [self.beginScanButton setBackgroundColor:[UIColor greenColor]];
//    [self.beginScanButton setBackgroundImage:[[UIImage imageNamed:@"button-destructive-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateNormal];
    [self.beginScanButton setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
    
    [self.beginScanButton addTarget:self action:@selector(didPressBeginScan:) forControlEvents:UIControlEventTouchUpInside];

    [self.beginScanButton setTitle:@"Scan for QR Code" forState:UIControlStateNormal];
    [self.beginScanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
    
    [self.beginScanButton setTitle:@"Scanning..." forState:UIControlStateDisabled];
    
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:60];

    
    [self.beginScanButton addConstraints:@[heightConstraint]];
    
    [self.view addSubview:self.beginScanButton];
}

- (void)setupButtonConstraints {
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.bottomLayoutGuide
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:-20];
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0
                                                                          constant:20];
    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1.0
                                                                           constant:-20];
    
    [self.view addConstraints:@[bottomConstraint,leadingConstraint,trailingConstraint]];
}

- (IBAction)didPressBeginScan:(id)sender {
    [self startSession];
}

#pragma NSNotification Handlers

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self stopSession];
}





















@end
