# Implementation Plan - Local Media Access (Offline Support)

This plan ensures that photos and sermons downloaded to the device are automatically used by the application instead of being fetched from the server, improving performance and allowing offline access.

## User Review Required

> [!NOTE]
> The app will automatically detect if a file (image or audio) is present locally. If it is, it will use the local version. This transition will be transparent to the user.

## Proposed Changes

### [Services & Infrastructure]

#### [MODIFY] [download_service.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/download_service.dart)
*   Add `getLocalAudioPath(String id)` and `getLocalImagePath(String id)` helpers.
*   Add `resolveImageUrl(String id, String remoteUrl)` to return either the local path or the remote URL.

#### [NEW] [smart_image.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/widget/smart_image.dart)
*   Create a reusable widget `SmartImage` that:
    *   Checks if the image (by ID or URL) is available locally via `DownloadService`.
    *   Uses `Image.file` if local, otherwise `Image.network`.
    *   Handles hero tags and loading states consistently.

### [UI Components]

#### [MODIFY] [sermon_player_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/sermon_player_page.dart)
*   Update `_initAudioPlayer` and skip methods to use `_audioPlayer.setFilePath(path)` if the sermon is downloaded.
*   Use `SmartImage` for the cover image.

#### [MODIFY] [galery_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/galery_page.dart)
*   Replace `Image.network` with `SmartImage` in the gallery grid/pageview.

#### [MODIFY] [image_viewer.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/widget/image_viewer.dart)
*   Update to support local files in the interactive viewer.

## Verification Plan

### Automated Tests
*   Verify that `DownloadService.resolveImageUrl` returns a valid file path string when the metadata entry exists.

### Manual Verification
1.  **Download a Sermon**: Go to the player, download the sermon. Close the app.
2.  **Offline Playback**: Turn off Wi-Fi/Data. Reopen the app and play the same sermon. It should play instantly and show the image without internet.
3.  **Gallery**: Download a photo in the gallery. Close app, go offline, and verify the photo still appears in the gallery and the viewer.
4.  **Delete**: Delete a download and verify the app reverts to using the remote URL (requires internet).

