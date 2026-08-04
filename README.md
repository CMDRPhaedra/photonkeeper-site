# photonkeeper-site

The download page for Photonkeeper, served at
[photonkeeper.chryse.co.uk](https://photonkeeper.chryse.co.uk/) via GitHub Pages.

Public on purpose: this repo holds only the built, notarised app and the page
around it. The source lives in the private `photonkeeper` repo.

## Releasing a new build

1. `./App/build.sh --notarize` in the source repo.
2. `ditto -c -k --keepParent App/build/Photonkeeper.app Photonkeeper-<version>.zip`
3. Drop the zip here, update the version, size, filename and SHA-256 in
   `index.html`, and remove the previous zip.
4. Commit and push. Pages redeploys on its own.

Keeping one zip at a time on purpose: every version committed here stays in
git history forever. If releases get frequent, move the binaries to GitHub
Releases and point the page at the latest instead.
