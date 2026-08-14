# photonkeeper-site

The page for Photonkeeper, served at
[photonkeeper.chryse.co.uk](https://photonkeeper.chryse.co.uk/) via GitHub Pages.

Public on purpose: this repo holds only the page, its screenshots and its
translations. The source lives in the private `photonkeeper` repo, and the app
itself is distributed by the
[Mac App Store](https://apps.apple.com/app/photonkeeper/id6799277298).

## Releasing a new build

1. `./App/build.sh --pkg` in the source repo.
2. Upload `App/build/Photonkeeper.pkg` to App Store Connect with Transporter.
3. Once the build is **approved**, update the version in `index.html`,
   `ja/index.html` and `zh-Hans/index.html` — the `.meta` line under the badge
   and `softwareVersion` in the schema.org block, in all three.
4. Commit and push. Pages redeploys on its own.

Approval, not submission: a page advertising a version review has not passed
yet is a page that lies for however many days the review takes.

## version.json

Kept for the directly-distributed builds still in the wild — 1.9 and earlier,
which poll it once a day and show a banner. It now names the App Store release
and links there, so the banner reads as a migration notice.

The App Store build never touches it: `--app-store` passes `-D APP_STORE`,
which compiles the whole update check, feed URL included, out of the binary. So
this file only ever affects the legacy direct builds, and the banner headline
those builds render is hard-coded as "Version X is available" — the version
here must stay numerically greater than 1.9 or no banner appears at all.
