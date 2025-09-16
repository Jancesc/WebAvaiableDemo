//
//  ZKHeader.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#ifndef ZKHeader_h
#define ZKHeader_h

typedef enum {
  XSNTC_kParserState_Undefined = 0,
  XSNTC_kParserState_Start,
  XSNTC_kParserState_Headers,
  XSNTC_kParserState_Content,
  XSNTC_kParserState_End
} XSNTC_kParserState;

#import "ZKServerFunctions.h"
#define kMultiPartBufferSize (256 * 1024)

#define kZlibErrorDomain @"ZlibErrorDomain"
#define kGZipInitialBufferSize (256 * 1024)
static NSData* XSNTC_newlineData = nil;
static NSData* XSNTC_newlinesData = nil;
static NSData* XSNTC_dashNewlineData = nil;


typedef void (^XSNTC_jkServerBodyReaderCompletionBlock)(NSData* _Nullable data, NSError* _Nullable error);


@protocol XSNTC_jkServerBodyReader <NSObject>
@required

- (BOOL)FDD_open:(NSError**)error;

- (nullable NSData*)FDD_readData:(NSError**)error;

- (void)FDD_close;

@optional

- (void)FDD_asyncReadDataWithCompletion:(XSNTC_jkServerBodyReaderCompletionBlock)block;

@end
@protocol XSNTC_jkServerBodyWriter <NSObject>


- (BOOL)FDD_open:(NSError**)error;


- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error;


- (BOOL)FDD_close:(NSError**)error;

@end

#endif /* ZKHeader_h */
