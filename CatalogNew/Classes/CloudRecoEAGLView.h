/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/


#import <UIKit/UIKit.h>

#import <QCAR/UIGLViewProtocol.h>
#import <QCAR/TrackableResult.h>
#import <QCAR/Vectors.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
//#import "A
#import "VideoPlayerHelper.h"


#define NUM_AUGMENTATION_TEXTURES 5
#define NUM_VIDEO_TARGETS 2


// structure to point to an object to be drawn
@interface Object3D : NSObject {
    unsigned int numVertices;
    const float *vertices;
    const float *normals;
    const float *texCoords;
    
    unsigned int numIndices;
    const unsigned short *indices;
    
    Texture *texture;
}
@property (nonatomic) unsigned int numVertices;
@property (nonatomic) const float *vertices;
@property (nonatomic) const float *normals;
@property (nonatomic) const float *texCoords;

@property (nonatomic) unsigned int numIndices;
@property (nonatomic) const unsigned short *indices;

@property (nonatomic, assign) Texture *texture;

@end


@class CloudRecoViewController;


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface CloudRecoEAGLView : UIView <UIGLViewProtocol> {
@private
    // Instantiate one VideoPlayerHelper per target
    VideoPlayerHelper* videoPlayerHelper[NUM_VIDEO_TARGETS];
    float videoPlaybackTime[NUM_VIDEO_TARGETS];
    
    VideoPlaybackViewController * videoPlaybackViewController ;
    // Timer to pause on-texture video playback after tracking has been lost.
    // Note: written/read on two threads, but never concurrently
    NSTimer* trackingLostTimer;
    
    // Coordinates of user touch
    float touchLocation_X;
    float touchLocation_Y;
    
    // indicates how the video will be played
    BOOL playVideoFullScreen;
    
    // Lock to synchronise data that is (potentially) accessed concurrently
    NSLock* dataLock;
    
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[NUM_AUGMENTATION_TEXTURES];

    BOOL offTargetTrackingEnabled;
    
    SampleApplicationSession * vapp;
    CloudRecoViewController * viewController;
}


- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app viewController:(CloudRecoViewController *) viewController;
- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void) willPlayVideoFullScreen:(BOOL) fullScreen;

- (void) prepare;
- (void) dismiss;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (bool) handleTouchPoint:(CGPoint) touchPoint;

- (void) preparePlayers;
- (void) dismissPlayers;



@end
