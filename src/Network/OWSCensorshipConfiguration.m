// Created by Michael Kirk on 12/20/16.
// Copyright © 2016 Open Whisper Systems. All rights reserved.

#import "OWSCensorshipConfiguration.h"
#import "TSStorageManager.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const OWSCensorshipConfigurationReflectorHost = @"signal-reflector-meek.appspot.com";

@implementation OWSCensorshipConfiguration

- (NSString *)frontingHost:(NSString *)e164PhonNumber
{
    OWSAssert(e164PhonNumber.length > 0);
    
    NSString *domain = nil;
    for (NSString *countryCode in self.censoredCountryCodes) {
        if ([e164PhonNumber hasPrefix:countryCode]) {
            domain = self.censoredCountryCodes[countryCode];
        }
    }
    
    // Fronting should only be used for countries specified in censoredCountryCodes,
    // all of which have a domain specified.
    OWSAssert(domain);
    if (!domain) {
        domain = @"google.com";
    }
    
    return [@"https://" stringByAppendingString:domain];
}

- (NSString *)reflectorHost
{
    return OWSCensorshipConfigurationReflectorHost;
}

- (NSDictionary<NSString *, NSString *> *)censoredCountryCodes
{
    // The set of countries for which domain fronting should be used.
    //
    // For each country, we should add the appropriate google domain,
    // per:  https://en.wikipedia.org/wiki/List_of_Google_domains
    //
    // If we ever use any non-google domains for domain fronting,
    // remember to:
    //
    // a) Add the appropriate pinning certificate(s) in
    //    SignalServiceKit.podspec.
    // b) Update reflectorHost accordingly.
    return @{
             // Egypt
             @"+20": @"google.com.eg",
             // Cuba
             @"+53": @"google.com.cu",
             // Oman
             @"+968": @"google.com.om",
             // UAE
             @"+971": @"google.ae",
             };
}

- (BOOL)isCensoredPhoneNumber:(NSString *)e164PhonNumber
{
    for (NSString *countryCode in self.censoredCountryCodes) {
        if ([e164PhonNumber hasPrefix:countryCode]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Logging

+ (NSString *)tag
{
    return [NSString stringWithFormat:@"[%@]", self.class];
}

- (NSString *)tag
{
    return self.class.tag;
}

@end

NS_ASSUME_NONNULL_END
