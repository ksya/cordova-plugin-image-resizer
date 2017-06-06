#import "ImageResizer.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPluginResult.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define PROTONET_PHOTO_PREFIX @"protonet_"

//static NSInteger count = 0;

@implementation ImageResizer {
}

- (void) resize:(CDVInvokedUrlCommand*)command
{
    __block PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];

    imageRequestOptions.synchronous = YES;

    NSLog(@"IMAGE RESIZER START ----------------------------------------------------------------------------");

    // get the arguments and the stuff inside of it
    NSDictionary* arguments = [command.arguments objectAtIndex:0];
    NSString* imageUrlString = [arguments objectForKey:@"uri"];
    NSLog(@"Image Resizer Image URL : %@",imageUrlString);

    NSString* quality = [arguments objectForKey:@"quality"];
    CGSize frameSize = CGSizeMake([[arguments objectForKey:@"width"] floatValue], [[arguments objectForKey:@"height"] floatValue]);

    //    //Get the image from the path
    NSURL* imageURL = [NSURL URLWithString:imageUrlString];

    __block UIImage *tempImage = nil;
    PHFetchResult *savedAssets = [PHAsset fetchAssetsWithALAssetURLs:@[imageURL] options:nil];	


    PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[fileName] options:nil];
    [savedAssets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        //this gets called for every asset from its localIdentifier you saved

        [[PHImageManager defaultManager] requestImageForAsset:asset
                           targetSize:frameSize
                          contentMode:PHImageContentModeDefault
                              options:imageRequestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            tempImage = image;
                        }];

    }];

   
    NSLog(@"image resizer:%@",  (tempImage  ? @"image exsist" : @"null" ));


    NSData *imageData = UIImageJPEGRepresentation(tempImage, [quality floatValue] / 100.0f );

    //NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"img%d.jpeg",count]];
    NSString* imagePath = [self tempFilePath:@"jpg"];
    //count++;
    CDVPluginResult* result = nil;

    if (![imageData writeToFile:imagePath atomically:NO])
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:@"error save image"];
    }
    else
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:imagePath] absoluteString]];
    }

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - Utilites

- (NSString*)tempFilePath:(NSString*)extension
{
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by Apple (vs [NSFileManager defaultManager]) to be threadsafe
    NSString* filePath;
    
    // generate unique file name
    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, extension];
    } while ([fileMgr fileExistsAtPath:filePath]);
    
    return filePath;
}

@end
