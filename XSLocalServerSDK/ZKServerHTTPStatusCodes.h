#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, XSNTC_ZKServerInformationalHTTPStatusCode) {
  XSNTC_kServerHTTPStatusCode_Continue = 100,
  XSNTC_kServerHTTPStatusCode_SwitchingProtocols = 101,
  XSNTC_kServerHTTPStatusCode_Processing = 102
};


typedef NS_ENUM(NSInteger, XSNTC_ZKServerSuccessfulHTTPStatusCode) {
  XSNTC_kServerHTTPStatusCode_OK = 200,
  XSNTC_kServerHTTPStatusCode_Created = 201,
  XSNTC_kServerHTTPStatusCode_Accepted = 202,
  XSNTC_kServerHTTPStatusCode_NonAuthoritativeInformation = 203,
  XSNTC_kServerHTTPStatusCode_NoContent = 204,
  XSNTC_kServerHTTPStatusCode_ResetContent = 205,
  XSNTC_kServerHTTPStatusCode_PartialContent = 206,
  XSNTC_kServerHTTPStatusCode_MultiStatus = 207,
  XSNTC_kServerHTTPStatusCode_AlreadyReported = 208
};


typedef NS_ENUM(NSInteger, XSNTC_ZKServerRedirectionHTTPStatusCode) {
  XSNTC_kServerHTTPStatusCode_MultipleChoices = 300,
  XSNTC_kServerHTTPStatusCode_MovedPermanently = 301,
  XSNTC_kServerHTTPStatusCode_Found = 302,
  XSNTC_kServerHTTPStatusCode_SeeOther = 303,
  XSNTC_kServerHTTPStatusCode_NotModified = 304,
  XSNTC_kServerHTTPStatusCode_UseProxy = 305,
  XSNTC_kServerHTTPStatusCode_TemporaryRedirect = 307,
  XSNTC_kServerHTTPStatusCode_PermanentRedirect = 308
};


typedef NS_ENUM(NSInteger, XSNTC_ZKServerClientErrorHTTPStatusCode) {
  XSNTC_kServerHTTPStatusCode_BadRequest = 400,
  XSNTC_kServerHTTPStatusCode_Unauthorized = 401,
  XSNTC_kServerHTTPStatusCode_PaymentRequired = 402,
  XSNTC_kServerHTTPStatusCode_Forbidden = 403,
  XSNTC_kServerHTTPStatusCode_NotFound = 404,
  XSNTC_kServerHTTPStatusCode_MethodNotAllowed = 405,
  XSNTC_kServerHTTPStatusCode_NotAcceptable = 406,
  XSNTC_kServerHTTPStatusCode_ProxyAuthenticationRequired = 407,
  XSNTC_kServerHTTPStatusCode_RequestTimeout = 408,
  XSNTC_kServerHTTPStatusCode_Conflict = 409,
  XSNTC_kServerHTTPStatusCode_Gone = 410,
  XSNTC_kServerHTTPStatusCode_LengthRequired = 411,
  XSNTC_kServerHTTPStatusCode_PreconditionFailed = 412,
  XSNTC_kServerHTTPStatusCode_RequestEntityTooLarge = 413,
  XSNTC_kServerHTTPStatusCode_RequestURITooLong = 414,
  XSNTC_kServerHTTPStatusCode_UnsupportedMediaType = 415,
  XSNTC_kServerHTTPStatusCode_RequestedRangeNotSatisfiable = 416,
  XSNTC_kServerHTTPStatusCode_ExpectationFailed = 417,
  XSNTC_kServerHTTPStatusCode_UnprocessableEntity = 422,
  XSNTC_kServerHTTPStatusCode_Locked = 423,
  XSNTC_kServerHTTPStatusCode_FailedDependency = 424,
  XSNTC_kServerHTTPStatusCode_UpgradeRequired = 426,
  XSNTC_kServerHTTPStatusCode_PreconditionRequired = 428,
  XSNTC_kServerHTTPStatusCode_TooManyRequests = 429,
  XSNTC_kServerHTTPStatusCode_RequestHeaderFieldsTooLarge = 431
};


typedef NS_ENUM(NSInteger, XSNTC_ZKServerServerErrorHTTPStatusCode) {
  XSNTC_kServerHTTPStatusCode_InternalServerError = 500,
  XSNTC_kServerHTTPStatusCode_NotImplemented = 501,
  XSNTC_kServerHTTPStatusCode_BadGateway = 502,
  XSNTC_kServerHTTPStatusCode_ServiceUnavailable = 503,
  XSNTC_kServerHTTPStatusCode_GatewayTimeout = 504,
  XSNTC_kServerHTTPStatusCode_HTTPVersionNotSupported = 505,
  XSNTC_kServerHTTPStatusCode_InsufficientStorage = 507,
  XSNTC_kServerHTTPStatusCode_LoopDetected = 508,
  XSNTC_kServerHTTPStatusCode_NotExtended = 510,
  XSNTC_kServerHTTPStatusCode_NetworkAuthenticationRequired = 511
};
