package com.tappygames.godotadmob

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.google.android.gms.ads.*
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class GodotAdMob(godot: Godot) : GodotPlugin(godot) {
    private lateinit var activity: Activity
    private var adView: AdView? = null
    private var interstitialAd: InterstitialAd? = null
    private var rewardedAd: RewardedAd? = null
    private var isInitialized = false
    private var layout: FrameLayout? = null

    override fun getPluginName() = "GodotAdMob"

    override fun getPluginSignals(): Set<SignalInfo> {
        return setOf(
            SignalInfo("banner_loaded"),
            SignalInfo("banner_failed_to_load", Int::class.java),
            SignalInfo("banner_opened"),
            SignalInfo("banner_closed"),
            SignalInfo("banner_clicked"),
            SignalInfo("interstitial_loaded"),
            SignalInfo("interstitial_failed_to_load", Int::class.java),
            SignalInfo("interstitial_opened"),
            SignalInfo("interstitial_closed"),
            SignalInfo("rewarded_ad_loaded"),
            SignalInfo("rewarded_ad_failed_to_load", Int::class.java),
            SignalInfo("rewarded_ad_opened"),
            SignalInfo("rewarded_ad_closed"),
            SignalInfo("rewarded_user_earned_reward", String::class.java, Int::class.java)
        )
    }

    override fun onMainCreate(activity: Activity?): View? {
        this.activity = activity ?: return null
        layout = FrameLayout(activity)
        return layout
    }

    @UsedByGodot
    fun initialize(
        appId: String,
        testMode: Boolean,
        childDirected: Boolean,
        maxContentRating: String,
        testDevices: Array<String>
    ) {
        activity.runOnUiThread {
            MobileAds.initialize(activity) {
                isInitialized = true
            }

            val requestConfigBuilder = MobileAds.getRequestConfiguration().toBuilder()
            
            if (testMode && testDevices.isNotEmpty()) {
                requestConfigBuilder.setTestDeviceIds(testDevices.toList())
            }
            
            val rating = when (maxContentRating) {
                "G" -> RequestConfiguration.MAX_AD_CONTENT_RATING_G
                "PG" -> RequestConfiguration.MAX_AD_CONTENT_RATING_PG
                "T" -> RequestConfiguration.MAX_AD_CONTENT_RATING_T
                "MA" -> RequestConfiguration.MAX_AD_CONTENT_RATING_MA
                else -> RequestConfiguration.MAX_AD_CONTENT_RATING_G
            }
            requestConfigBuilder.setMaxAdContentRating(rating)
            
            if (childDirected) {
                requestConfigBuilder.setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE)
            }
            
            MobileAds.setRequestConfiguration(requestConfigBuilder.build())
        }
    }

    @UsedByGodot
    fun loadBanner(adUnitId: String, size: Int, position: Int) {
        if (!isInitialized) return

        activity.runOnUiThread {
            adView?.destroy()
            adView = AdView(activity).apply {
                setAdSize(getAdSize(size))
                adUnitId = adUnitId
                
                adListener = object : AdListener() {
                    override fun onAdLoaded() {
                        emitSignal("banner_loaded")
                    }

                    override fun onAdFailedToLoad(error: LoadAdError) {
                        emitSignal("banner_failed_to_load", error.code)
                    }

                    override fun onAdOpened() {
                        emitSignal("banner_opened")
                    }

                    override fun onAdClosed() {
                        emitSignal("banner_closed")
                    }

                    override fun onAdClicked() {
                        emitSignal("banner_clicked")
                    }
                }
                
                loadAd(AdRequest.Builder().build())
            }

            layout?.let { parent ->
                parent.removeAllViews()
                val params = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                )
                params.gravity = getGravity(position)
                parent.addView(adView, params)
            }
        }
    }

    @UsedByGodot
    fun showBanner() {
        activity.runOnUiThread {
            adView?.visibility = View.VISIBLE
        }
    }

    @UsedByGodot
    fun hideBanner() {
        activity.runOnUiThread {
            adView?.visibility = View.GONE
        }
    }

    @UsedByGodot
    fun destroyBanner() {
        activity.runOnUiThread {
            adView?.destroy()
            adView = null
            layout?.removeAllViews()
        }
    }

    @UsedByGodot
    fun loadInterstitial(adUnitId: String) {
        if (!isInitialized) return

        activity.runOnUiThread {
            InterstitialAd.load(
                activity,
                adUnitId,
                AdRequest.Builder().build(),
                object : InterstitialAdLoadCallback() {
                    override fun onAdLoaded(ad: InterstitialAd) {
                        interstitialAd = ad
                        emitSignal("interstitial_loaded")
                        
                        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                            override fun onAdShowedFullScreenContent() {
                                emitSignal("interstitial_opened")
                            }

                            override fun onAdDismissedFullScreenContent() {
                                emitSignal("interstitial_closed")
                                interstitialAd = null
                            }

                            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                                interstitialAd = null
                            }
                        }
                    }

                    override fun onAdFailedToLoad(error: LoadAdError) {
                        emitSignal("interstitial_failed_to_load", error.code)
                        interstitialAd = null
                    }
                }
            )
        }
    }

    @UsedByGodot
    fun showInterstitial() {
        activity.runOnUiThread {
            interstitialAd?.show(activity)
        }
    }

    @UsedByGodot
    fun loadRewardedAd(adUnitId: String) {
        if (!isInitialized) return

        activity.runOnUiThread {
            RewardedAd.load(
                activity,
                adUnitId,
                AdRequest.Builder().build(),
                object : RewardedAdLoadCallback() {
                    override fun onAdLoaded(ad: RewardedAd) {
                        rewardedAd = ad
                        emitSignal("rewarded_ad_loaded")
                        
                        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                            override fun onAdShowedFullScreenContent() {
                                emitSignal("rewarded_ad_opened")
                            }

                            override fun onAdDismissedFullScreenContent() {
                                emitSignal("rewarded_ad_closed")
                                rewardedAd = null
                            }

                            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                                rewardedAd = null
                            }
                        }
                    }

                    override fun onAdFailedToLoad(error: LoadAdError) {
                        emitSignal("rewarded_ad_failed_to_load", error.code)
                        rewardedAd = null
                    }
                }
            )
        }
    }

    @UsedByGodot
    fun showRewardedAd() {
        activity.runOnUiThread {
            rewardedAd?.show(activity) { reward ->
                emitSignal("rewarded_user_earned_reward", reward.type, reward.amount)
            }
        }
    }

    private fun getAdSize(size: Int): AdSize {
        return when (size) {
            0 -> AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, AdSize.FULL_WIDTH)
            1 -> AdSize.SMART_BANNER
            2 -> AdSize.BANNER
            3 -> AdSize.MEDIUM_RECTANGLE
            4 -> AdSize.FULL_BANNER
            5 -> AdSize.LEADERBOARD
            else -> AdSize.BANNER
        }
    }

    private fun getGravity(position: Int): Int {
        return when (position) {
            0 -> android.view.Gravity.TOP or android.view.Gravity.CENTER_HORIZONTAL
            1 -> android.view.Gravity.BOTTOM or android.view.Gravity.CENTER_HORIZONTAL
            2 -> android.view.Gravity.TOP or android.view.Gravity.LEFT
            3 -> android.view.Gravity.TOP or android.view.Gravity.RIGHT
            4 -> android.view.Gravity.BOTTOM or android.view.Gravity.LEFT
            5 -> android.view.Gravity.BOTTOM or android.view.Gravity.RIGHT
            6 -> android.view.Gravity.CENTER
            else -> android.view.Gravity.BOTTOM or android.view.Gravity.CENTER_HORIZONTAL
        }
    }
}