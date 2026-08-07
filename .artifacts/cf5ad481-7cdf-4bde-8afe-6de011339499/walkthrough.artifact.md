# Walkthrough - Persistent Sessions & Proactive Refresh (Day 6)

I have implemented a robust session persistence mechanism that ensures users stay logged in indefinitely as long as they open the app at least once every 30 days, with a proactive refresh triggered on the 6th day of the Access Token's life.

## Changes Made

### 1. Token Persistence and Management
- **Persistent Access Token**: The `access_token` is now stored in `FlutterSecureStorage` alongside the `refresh_token`. This allows for "instant login" on app restart without a network call if the token is still fresh.
- **Refresh Timestamp**: I added a `last_refresh_timestamp` to track exactly when the session was last renewed.

### 2. Proactive Refresh Logic (Day 6)
- **Startup Check**: In `AuthService.restoreSession()`, the app now calculates the age of the Access Token.
    - If `< 6 days`: It uses the token immediately and verifies it with a quick `/me` call.
    - If `>= 6 days`: It proactively calls `/refresh` to get a new set of tokens, resetting the 7-day (access) and 30-day (refresh) clocks.
- **Hourly Background Timer**: While the app is open, a `Timer.periodic` checks every hour if the 6-day threshold has been reached. This handles long-running sessions without requiring a restart.

### 3. UI Optimization
- **SplashScreen**: The splash screen now initiates the session restoration in parallel with the animation, reducing the perceived wait time for the user.

## Files Modified

- [AuthService.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/apiService/auth_service.dart): Core logic for persistence and timers.
- [SplashScreen.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/splash_screen.dart): Optimized startup flow.

## How to Verify

1. **Instant Persistence**: Log in, close the app, and reopen it. You should be logged in immediately.
2. **Proactive Refresh**: To test the 6-day logic without waiting, you can temporarily modify the code in `AuthService.dart` to use `inSeconds` instead of `inDays` for the check, or manually set a past date in the secure storage if you have access to a debugger.
3. **Logout**: Verify that clicking logout clears all three keys (`access_token`, `refresh_token`, `last_refresh_timestamp`) from the secure storage.

> [!TIP]
> This approach is highly battery-efficient as it relies on simple timestamp comparisons and only performs network activity when strictly necessary or when the app is already being used.
