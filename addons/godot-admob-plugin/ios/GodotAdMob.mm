#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#include "core/config/engine.h"
#include "core/object/class_db.h"

class GodotAdMob : public Object {
    GDCLASS(GodotAdMob, Object);
    
    GADBannerView *bannerView;
    GADInterstitialAd *interstitialAd;
    GADRewardedAd *rewardedAd;
    
    bool isInitialized;
    bool testMode;
    
    UIViewController *rootViewController;
    
protected:
    static void _bind_methods();
    
public:
    void initialize(String app_id, bool test_mode, bool child_directed, String max_rating, Array test_devices);
    
    void load_banner(String ad_unit_id, int size, int position);
    void show_banner();
    void hide_banner();
    void destroy_banner();
    
    void load_interstitial(String ad_unit_id);
    void show_interstitial();
    
    void load_rewarded_ad(String ad_unit_id);
    void show_rewarded_ad();
    
    GodotAdMob();
    ~GodotAdMob();
};

void GodotAdMob::_bind_methods() {
    ClassDB::bind_method(D_METHOD("initialize", "app_id", "test_mode", "child_directed", "max_rating", "test_devices"), &GodotAdMob::initialize);
    ClassDB::bind_method(D_METHOD("load_banner", "ad_unit_id", "size", "position"), &GodotAdMob::load_banner);
    ClassDB::bind_method(D_METHOD("show_banner"), &GodotAdMob::show_banner);
    ClassDB::bind_method(D_METHOD("hide_banner"), &GodotAdMob::hide_banner);
    ClassDB::bind_method(D_METHOD("destroy_banner"), &GodotAdMob::destroy_banner);
    ClassDB::bind_method(D_METHOD("load_interstitial", "ad_unit_id"), &GodotAdMob::load_interstitial);
    ClassDB::bind_method(D_METHOD("show_interstitial"), &GodotAdMob::show_interstitial);
    ClassDB::bind_method(D_METHOD("load_rewarded_ad", "ad_unit_id"), &GodotAdMob::load_rewarded_ad);
    ClassDB::bind_method(D_METHOD("show_rewarded_ad"), &GodotAdMob::show_rewarded_ad);
    
    ADD_SIGNAL(MethodInfo("banner_loaded"));
    ADD_SIGNAL(MethodInfo("banner_failed_to_load", PropertyInfo(Variant::INT, "error_code")));
    ADD_SIGNAL(MethodInfo("banner_opened"));
    ADD_SIGNAL(MethodInfo("banner_closed"));
    ADD_SIGNAL(MethodInfo("banner_clicked"));
    
    ADD_SIGNAL(MethodInfo("interstitial_loaded"));
    ADD_SIGNAL(MethodInfo("interstitial_failed_to_load", PropertyInfo(Variant::INT, "error_code")));
    ADD_SIGNAL(MethodInfo("interstitial_opened"));
    ADD_SIGNAL(MethodInfo("interstitial_closed"));
    
    ADD_SIGNAL(MethodInfo("rewarded_ad_loaded"));
    ADD_SIGNAL(MethodInfo("rewarded_ad_failed_to_load", PropertyInfo(Variant::INT, "error_code")));
    ADD_SIGNAL(MethodInfo("rewarded_ad_opened"));
    ADD_SIGNAL(MethodInfo("rewarded_ad_closed"));
    ADD_SIGNAL(MethodInfo("rewarded_user_earned_reward", PropertyInfo(Variant::STRING, "currency"), PropertyInfo(Variant::INT, "amount")));
}

GodotAdMob::GodotAdMob() {
    bannerView = nil;
    interstitialAd = nil;
    rewardedAd = nil;
    isInitialized = false;
    testMode = false;
    rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
}

GodotAdMob::~GodotAdMob() {
    if (bannerView) {
        [bannerView removeFromSuperview];
        bannerView = nil;
    }
}

void GodotAdMob::initialize(String app_id, bool test_mode, bool child_directed, String max_rating, Array test_devices) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
            isInitialized = true;
        }];
        
        GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[];
        
        if (test_mode && test_devices.size() > 0) {
            NSMutableArray *devices = [NSMutableArray array];
            for (int i = 0; i < test_devices.size(); i++) {
                String device = test_devices[i];
                [devices addObject:[NSString stringWithUTF8String:device.utf8().get_data()]];
            }
            GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = devices;
        }
        
        if (child_directed) {
            GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = @YES;
        }
        
        GADMaxAdContentRating rating = GADMaxAdContentRatingGeneral;
        if (max_rating == "G") {
            rating = GADMaxAdContentRatingGeneral;
        } else if (max_rating == "PG") {
            rating = GADMaxAdContentRatingParentalGuidance;
        } else if (max_rating == "T") {
            rating = GADMaxAdContentRatingTeen;
        } else if (max_rating == "MA") {
            rating = GADMaxAdContentRatingMatureAudience;
        }
        GADMobileAds.sharedInstance.requestConfiguration.maxAdContentRating = rating;
        
        this->testMode = test_mode;
    });
}

void GodotAdMob::load_banner(String ad_unit_id, int size, int position) {
    if (!isInitialized) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bannerView) {
            [bannerView removeFromSuperview];
            bannerView = nil;
        }
        
        GADAdSize adSize;
        switch (size) {
            case 0:
                adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(rootViewController.view.frame.size.width);
                break;
            case 1:
                adSize = kGADAdSizeSmartBannerPortrait;
                break;
            case 2:
                adSize = kGADAdSizeBanner;
                break;
            case 3:
                adSize = kGADAdSizeMediumRectangle;
                break;
            case 4:
                adSize = kGADAdSizeFullBanner;
                break;
            case 5:
                adSize = kGADAdSizeLeaderboard;
                break;
            default:
                adSize = kGADAdSizeBanner;
                break;
        }
        
        bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
        bannerView.adUnitID = [NSString stringWithUTF8String:ad_unit_id.utf8().get_data()];
        bannerView.rootViewController = rootViewController;
        
        [rootViewController.view addSubview:bannerView];
        
        bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        switch (position) {
            case 0: // TOP
                [NSLayoutConstraint activateConstraints:@[
                    [bannerView.topAnchor constraintEqualToAnchor:rootViewController.view.safeAreaLayoutGuide.topAnchor],
                    [bannerView.centerXAnchor constraintEqualToAnchor:rootViewController.view.centerXAnchor]
                ]];
                break;
            case 1: // BOTTOM
                [NSLayoutConstraint activateConstraints:@[
                    [bannerView.bottomAnchor constraintEqualToAnchor:rootViewController.view.safeAreaLayoutGuide.bottomAnchor],
                    [bannerView.centerXAnchor constraintEqualToAnchor:rootViewController.view.centerXAnchor]
                ]];
                break;
            case 6: // CENTER
                [NSLayoutConstraint activateConstraints:@[
                    [bannerView.centerXAnchor constraintEqualToAnchor:rootViewController.view.centerXAnchor],
                    [bannerView.centerYAnchor constraintEqualToAnchor:rootViewController.view.centerYAnchor]
                ]];
                break;
            default:
                [NSLayoutConstraint activateConstraints:@[
                    [bannerView.bottomAnchor constraintEqualToAnchor:rootViewController.view.safeAreaLayoutGuide.bottomAnchor],
                    [bannerView.centerXAnchor constraintEqualToAnchor:rootViewController.view.centerXAnchor]
                ]];
                break;
        }
        
        GADRequest *request = [GADRequest request];
        [bannerView loadRequest:request];
        
        emit_signal("banner_loaded");
    });
}

void GodotAdMob::show_banner() {
    if (!bannerView) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        bannerView.hidden = NO;
    });
}

void GodotAdMob::hide_banner() {
    if (!bannerView) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        bannerView.hidden = YES;
    });
}

void GodotAdMob::destroy_banner() {
    if (!bannerView) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [bannerView removeFromSuperview];
        bannerView = nil;
    });
}

void GodotAdMob::load_interstitial(String ad_unit_id) {
    if (!isInitialized) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GADRequest *request = [GADRequest request];
        NSString *adUnitID = [NSString stringWithUTF8String:ad_unit_id.utf8().get_data()];
        
        [GADInterstitialAd loadWithAdUnitID:adUnitID
                                     request:request
                           completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            if (error) {
                emit_signal("interstitial_failed_to_load", error.code);
            } else {
                interstitialAd = ad;
                emit_signal("interstitial_loaded");
            }
        }];
    });
}

void GodotAdMob::show_interstitial() {
    if (!interstitialAd) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [interstitialAd presentFromRootViewController:rootViewController];
        emit_signal("interstitial_opened");
    });
}

void GodotAdMob::load_rewarded_ad(String ad_unit_id) {
    if (!isInitialized) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GADRequest *request = [GADRequest request];
        NSString *adUnitID = [NSString stringWithUTF8String:ad_unit_id.utf8().get_data()];
        
        [GADRewardedAd loadWithAdUnitID:adUnitID
                                 request:request
                       completionHandler:^(GADRewardedAd *ad, NSError *error) {
            if (error) {
                emit_signal("rewarded_ad_failed_to_load", error.code);
            } else {
                rewardedAd = ad;
                emit_signal("rewarded_ad_loaded");
            }
        }];
    });
}

void GodotAdMob::show_rewarded_ad() {
    if (!rewardedAd) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [rewardedAd presentFromRootViewController:rootViewController
                          userDidEarnRewardHandler:^{
            GADAdReward *reward = rewardedAd.adReward;
            NSString *type = reward.type;
            NSInteger amount = reward.amount.integerValue;
            emit_signal("rewarded_user_earned_reward", String([type UTF8String]), (int)amount);
        }];
        emit_signal("rewarded_ad_opened");
    });
}