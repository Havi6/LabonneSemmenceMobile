# Task: Persistent Sessions & Proactive Refresh (Day 6)

- [ ] Modify `AuthService` for token persistence and proactive refresh <!-- id: 0 -->
    - [ ] Add constants for new storage keys (`_accessTokenKey`, `_lastRefreshKey`) <!-- id: 1 -->
    - [ ] Update `_storeSession` to persist access token and timestamp <!-- id: 2 -->
    - [ ] Update `_clearSession` to remove all persisted data <!-- id: 3 -->
    - [ ] Update `restoreSession` and `_doRestoreSession` to use stored access token if valid (< 6 days) <!-- id: 4 -->
    - [ ] Implement `_startProactiveRefresh()` with a periodic timer <!-- id: 5 -->
- [ ] Update `ApiClient` to sync with `AuthService` changes <!-- id: 6 -->
- [ ] Optimize `SplashScreen` to use instant login if session is valid <!-- id: 7 -->
- [ ] Verification <!-- id: 8 -->
    - [ ] Verify instant login after app restart <!-- id: 9 -->
    - [ ] Verify refresh triggers when timestamp > 6 days <!-- id: 10 -->
    - [ ] Verify logout clears everything <!-- id: 11 -->
