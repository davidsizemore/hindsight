# App Store Submission Walkthrough

Congratulations on finishing the new features! Here is a step-by-step guide to archiving your app and submitting the update to the Mac App Store.

## 1. Prepare for Release

Before archiving, ensure your version and build numbers are updated.

1.  **Open Xcode**.
2.  Select your **Project** in the Project Navigator (the blue icon at the very top left).
3.  Select the **Hindsight** target under "Targets".
4.  Go to the **General** tab.
5.  **Identity Section**:
    *   **Version**: Increment this (e.g., if it was `1.0`, make it `1.1`).
    *   **Build**: Increment this (e.g., if it was `1`, make it `2`). Every upload to App Store Connect *must* have a unique build number.

> [!IMPORTANT]
> **Timer Verification**: Remember that your `AppState.swift` uses conditional compilation.
> *   **Debug**: 30 seconds (for testing)
> *   **Release**: 20 minutes (for users)
>
> When you **Archive**, Xcode automatically uses the **Release** configuration, so your app will correctly use the 20-minute timer. You do *not* need to change the code manually.

## 2. Archive the App

1.  Select **Product** > **Archive** from the menu bar.
2.  Xcode will build your app. This might take a moment.
3.  Once finished, the **Organizer** window will open automatically, showing your new archive.

## 3. Validate and Upload

1.  In the Organizer window, select your new archive (it should be at the top of the list).
2.  Click **Distribute App**.
3.  Select **App Store Connect** and click **Next**.
4.  Select **Upload** and click **Next**.
5.  Xcode will analyze your app and check for any issues.
    *   If asked about **Distribution Options**, usually the defaults (Upload your app's symbols, Manage Version and Build Number) are fine. Click **Next**.
    *   **Signing**: Select "Automatically manage signing" unless you have a specific manual setup. Click **Next**.
6.  Review the summary page and click **Upload**.
7.  Wait for the upload to complete. You should see a green checkmark saying "App \"Hindsight\" was successfully uploaded."

## 4. App Store Connect

1.  Go to [App Store Connect](https://appstoreconnect.apple.com) in your browser and log in.
2.  Click on **My Apps** and select **Hindsight**.
3.  In the left sidebar, click the **+** button next to **macOS App** (or select the "Ready for Sale" version and click "+ Version" at the top right) to create a new version.
    *   Enter the **Version Number** matching what you put in Xcode (e.g., `1.1`).
4.  **What's New**: Enter your release notes.
    *   *Example*: "Introduced Terminal Mode! You can now style your break reminders like a retro terminal window. Also improved performance and fixed minor bugs."
5.  **Build**: Scroll down to the "Build" section.
    *   Click **Add Build**.
    *   Select the build you just uploaded from Xcode. (It might take a few minutes to appear after uploading; if you don't see it, wait for an email from Apple saying it's done processing).
6.  **Review**: Check your screenshots and other metadata. Since you added a new visual mode, you might want to upload a new screenshot showing off Terminal Mode!
7.  Click **Save** (top right).
8.  Click **Add for Review**.

## 5. Waiting for Review

*   Your app status will change to "Waiting for Review".
*   Apple usually reviews apps within 24-48 hours.
*   You will receive an email when the status changes to "In Review" and then "Ready for Sale" (approved) or "Rejected" (if there are issues).

Good luck with the submission!
