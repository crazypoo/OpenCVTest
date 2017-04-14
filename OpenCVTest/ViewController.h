//
//  ViewController.h
//  OpenCVTest
//
//  Created by MYX on 2017/4/14.
//  Copyright © 2017年 邓杰豪. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/objdetect.hpp>
#import <opencv2/imgproc/imgproc_c.h>

using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>
{
    IBOutlet UIImageView* imageView;
    
    CvVideoCamera* videoCamera;
    CascadeClassifier faceCascade;
    CascadeClassifier eyes_cascade;
    CascadeClassifier mMouthDetector;
    CascadeClassifier mNoseDetector;
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;

- (IBAction)startCamera:(id)sender;
- (IBAction)stopCamera:(id)sender;
@end

