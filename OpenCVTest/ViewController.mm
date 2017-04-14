//
//  ViewController.m
//  OpenCVTest
//
//  Created by MYX on 2017/4/14.
//  Copyright © 2017年 邓杰豪. All rights reserved.
//

#import "ViewController.h"

NSString* const faceCascadeFilename = @"haarcascade_frontalface_alt";
NSString* const eyeCascadeFilename = @"haarcascade_eye_tree_eyeglasses";
NSString* const noseCascadeFilename = @"haarcascade_mcs_nose";
NSString* const mouthCascadeFilename = @"haarcascade_mcs_mouth";

const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@interface ViewController ()

@end

@implementation ViewController

@synthesize videoCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    
    NSString* faceCascadePath = [[NSBundle mainBundle] pathForResource:faceCascadeFilename ofType:@"xml"];
    NSString* eyeCascadePath = [[NSBundle mainBundle] pathForResource:eyeCascadeFilename ofType:@"xml"];
    NSString* noseCascadePath = [[NSBundle mainBundle] pathForResource:noseCascadeFilename ofType:@"xml"];
    NSString* mouthCascadePath = [[NSBundle mainBundle] pathForResource:mouthCascadeFilename ofType:@"xml"];

    faceCascade.load([faceCascadePath UTF8String]);
    eyes_cascade.load([eyeCascadePath UTF8String]);
    mNoseDetector.load([noseCascadePath UTF8String]);
    mMouthDetector.load([mouthCascadePath UTF8String]);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    Mat grayscaleFrame;
    cvtColor(image, grayscaleFrame, CV_BGR2GRAY);
    equalizeHist(grayscaleFrame, grayscaleFrame);
    
    std::vector<cv::Rect> faces;
    faceCascade.detectMultiScale(grayscaleFrame, faces, 1.1, 2, HaarOptions, cv::Size(60, 60));
    
    for (int i = 0; i < faces.size(); i++)
    {
        cv::Point pt1(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
        cv::Point pt2(faces[i].x, faces[i].y);
        
        cv::rectangle(image, pt1, pt2, cvScalar(0, 255, 0, 0), 1, 8 ,0);
        
        Mat faceROI = grayscaleFrame( faces[i] );
        std::vector<cv::Rect> eyes;//眼睛标注
        eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2,0|CV_HAAR_SCALE_IMAGE , cv::Size(30, 30) );
        for( size_t j = 0; j < eyes.size(); j++ )
        {
            cv::Point center( int(faces[i].x + eyes[j].x + eyes[j].width*0.5), int(faces[i].y + eyes[j].y + eyes[j].height*0.5) );
            int radius = cvRound( (eyes[j].width + eyes[i].height)*0.25 );
            circle( image, center, radius, Scalar( 255, 0, 0 ), 3, 8, 0 );
        }
        
        //检测鼻子
        std::vector< cv::Rect > noseVec;
        
        mNoseDetector.detectMultiScale( faceROI, noseVec, 3 );
        
        for(size_t z=0; z<noseVec.size(); z++ )
        {
            cv::Rect rect = noseVec[z];
            rect.x += faces[i].x;
            rect.y += faces[i].y;
            
            cv::rectangle( image, rect, CV_RGB(0,0,255), 2 );
        }
        
        //检测嘴巴
        std::vector< cv::Rect > mouthVec;
        cv::Rect halfRect = faces[i];
        halfRect.height /= 2;
        halfRect.y += halfRect.height/2;//取脸部的下半区域为检测区域，此时要加上脸的一半高度
        
        cv::Mat halfFace = image( halfRect );
        
        mMouthDetector.detectMultiScale( faceROI, mouthVec, 3 );
        
        for(size_t  j=0; j<mouthVec.size(); j++ )
        {
            cv::Rect rect = mouthVec[j];
            rect.x += halfRect.x;
            rect.y += halfRect.y;
            
            cv::rectangle( image, rect, CV_RGB(255,255,255), 2 );
        }
    }
}
#endif

#pragma mark - UI Actions

- (IBAction)startCamera:(id)sender
{
    [self.videoCamera start];
}

- (IBAction)stopCamera:(id)sender
{
    [self.videoCamera stop];
}

@end
