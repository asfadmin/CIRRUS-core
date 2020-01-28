# Patches

This directory contains patches for Cumulus defects. If / when the
defect is fixed and released, remove and document accordingly.

* fetch_or_create_rsa_keys.sh: A revised version of the Cumulus script
  that doesn't send stdout & stderr to /dev/null and won't
  accidentally send `openssl` stderr to s3 along with the public
  key. See Cumulus issues
  [#1437](https://github.com/nasa/cumulus/issues/1437) and
  [#1438](https://github.com/nasa/cumulus/issues/1438).
