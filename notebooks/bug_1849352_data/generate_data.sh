#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

rm -- *.csv

# All products by day broken down by platform
supersearchfacet \
    --_facets=platform \
    --start-date='2023-07-01' \
    --end-date='2023-09-01' \
    --period=daily \
    --format=csv \
    > crash_reports_by_platform.csv

# Windows by day broken down by product
supersearchfacet \
    --_facets=product \
    --platform=Windows \
    --start-date='2023-07-01' \
    --end-date='2023-09-01' \
    --period=daily \
    --format=csv \
    > windows_crash_reports_by_product.csv

# Firefox Windows broken down by release channel
supersearchfacet \
    --_facets=release_channel \
    --platform=Windows \
    --product=Firefox \
    --start-date='2023-07-01' \
    --end-date='2023-09-01' \
    --period=daily \
    --format=csv \
    > firefox_windows_crash_reports_by_channel.csv


# Firefox Windows release broken down by platform pretty version
supersearchfacet \
    --_facets=platform_pretty_version \
    --platform=Windows \
    --product=Firefox \
    --release_channel=release \
    --start-date='2023-07-01' \
    --end-date='2023-09-01' \
    --period=daily \
    --format=csv \
    > firefox_windows_release_crash_reports_by_platform.csv

 
# Firefox Windows esr broken down by platform pretty version
supersearchfacet \
    --_facets=platform_pretty_version \
    --platform=Windows \
    --product=Firefox \
    --release_channel=esr \
    --start-date='2023-07-01' \
    --end-date='2023-09-01' \
    --period=daily \
    --format=csv \
    > firefox_windows_esr_crash_reports_by_platform.csv


supersearchfacet \
    --_facets=signature \
    --platform=Windows \
    --product=Firefox \
    --release_channel=esr \
    --platform_pretty_version="Windows 7" \
    --start-date='2023-09-01' \
    --end-date='2023-09-08' \
    --format=csv \
    > firefox_windows_7_esr_top_crashers.csv
