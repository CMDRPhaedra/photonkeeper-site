# photonkeeper-site

The page for Photonkeeper, served at
[photonkeeper.chryse.co.uk](https://photonkeeper.chryse.co.uk/) via GitHub Pages.

Public on purpose: this repo holds only the page, its screenshots and its
translations. The source lives in the private `photonkeeper` repo, and the app
itself is distributed by the
[Mac App Store](https://apps.apple.com/app/photonkeeper/id6799277298) and the
[Microsoft Store](https://apps.microsoft.com/detail/9NM0K9T75QMZ).

## Releasing a new build

1. `./App/build.sh --pkg` in the source repo.
2. Upload `App/build/Photonkeeper.pkg` to App Store Connect with Transporter.
   For Windows, publish the two MSIX packages out of `windows/src/Photonkeeper`
   and submit them in Partner Center.
3. Nothing here needs changing for an ordinary release. Commit and push if
   something else did; Pages redeploys on its own.

**The page no longer names a version.** It used to, in three files and in the
schema.org block of each, updated on approval rather than on submission —
because a page advertising a version review has not passed yet lies for however
many days the review takes. Two stores with independent release cadences turned
that from one careful edit into two, each able to be wrong on its own, for a
number nobody chooses the app by. The `.meta` line under the badges now names
the platform requirements instead, which change about once a year.

The requirements do still need an edit when a minimum moves — the `.meta` line
and the Requirements list in all three languages, plus `operatingSystem` in the
schema.org block.

## version.json

Kept for the directly-distributed builds still in the wild — 1.9 and earlier,
which poll it once a day and show a banner. It now names the App Store release
and links there, so the banner reads as a migration notice.

The App Store build never touches it: `--app-store` passes `-D APP_STORE`,
which compiles the whole update check, feed URL included, out of the binary. So
this file only ever affects the legacy direct builds, and the banner headline
those builds render is hard-coded as "Version X is available" — the version
here must stay numerically greater than 1.9 or no banner appears at all.
