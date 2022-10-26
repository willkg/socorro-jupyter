#!/usr/bin/env python

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Downloads sym files with a given module name and captures information in csv file.
#
# Usage: symsizes.py [MODULENAME] [OUTPUTFILE]

import csv
import os
from urllib.parse import urljoin

import click
import requests


# Number of seconds to wait for a response from server
CONNECTION_TIMEOUT = 120

SYMBOLS_URL = "https://symbols.mozilla.org/"

USER_AGENT = "tecken/sym_sizes.py"


def get_sym_files(auth_token, url, modulename):
    """Given an auth token, generates (filename, size, created_at) tuples for SYM files.

    :param auth_token: auth token for symbols.mozilla.org
    :param url: url for file uploads
    :param modulename: the module to look for

    :returns: generator of (key, size) typles

    """
    page = 1
    params = {
        "page": page,
        "key": modulename,
        # "created_at": [">=2022-08-19", "<2022-08-21"],
        "created_at": [">=2022-10-21", "<2022-10-23"],
    }
    headers = {"auth-token": auth_token, "User-Agent": USER_AGENT}

    while True:
        params["page"] = page
        click.echo(f"page {page}")
        resp = requests.get(
            url,
            params=params,
            headers=headers,
            timeout=CONNECTION_TIMEOUT,
        )
        resp.raise_for_status()
        data = resp.json()

        yield from [
            (record["key"], record["size"], record["created_at"])
            for record in data["files"]

            # Skip try symbols and items that don't have the module substring in them
            if (
                record["upload"]["try_symbols"] is False
                # NOTE(willkg): This is a case-sensitive substring check
                and modulename in record["key"]
            )
        ]
        page += 1


def download_sym_file(auth_token, url):
    headers = {"auth-token": auth_token, "User-Agent": USER_AGENT}
    resp = requests.get(url, headers=headers, timeout=CONNECTION_TIMEOUT)
    if resp.status_code != 200:
        click.echo(click.style(f"Response: {resp.status_code}", fg="red"))
        return None, None

    # We don't want the actual file--we just want the sizes. requests automatically
    # uncompresses the file so resp.content has the uncompressed contents.
    #
    # Returns compressed size and actual size.
    return int(resp.headers["Content-Length"]), len(resp.content)


@click.command()
@click.option(
    "--auth-token",
    required=True,
    help="Auth token for symbols.mozilla.org.",
)
@click.option(
    "--num",
    default=10,
    help="Number of files to download.",
)
@click.argument("modulename")
@click.argument("outputfile")
@click.pass_context
def download_symbols_by_name(ctx, auth_token, num, modulename, outputfile):
    """
    Downloads symbols with a given module name and captures information in csv file.

    Note: This requires an auth token for symbols.mozilla.org to view files.

    """
    mode = "w"

    already_have = set()
    if os.path.exists(outputfile):
        mode = "a"
        with open(outputfile, "rb") as fp:
            for line in fp.readlines():
                line = line.decode("utf-8")
                if line.startswith("module"):
                    continue

                parts = line.split(",")

                already_have.add((parts[0], parts[1], parts[2]))

    current_num = 0

    with open(outputfile, mode, newline="") as fp:
        csvwriter = csv.writer(fp)

        if mode == "w":
            csvwriter.writerow(["module", "debug_id", "debug_filename", "url", "size", "compressed_size"])

        sym_files_url = urljoin(SYMBOLS_URL, "/api/uploads/files/content/")
        sym_files_generator = get_sym_files(auth_token, sym_files_url, modulename=modulename)
        for sym_filename, sym_size, created_at in sym_files_generator:
            if current_num > num:
                break

            if not sym_filename.endswith(".sym"):
                continue

            if sym_filename.startswith("try/"):
                sym_filename = sym_filename[4:]

            if sym_filename.startswith("v1/"):
                sym_filename = sym_filename[3:]

            module, debug_id, debug_filename = sym_filename.split("/")[-3:]

            if (module, debug_id, debug_filename) in already_have:
                click.echo(f"({current_num}/{num}) Skipping {sym_filename} -- already have ...")
                current_num += 1
                continue

            url = urljoin(SYMBOLS_URL, sym_filename)

            click.echo(f"({current_num}/{num}) Checking {sym_filename} ({created_at}) ...")
            compressed_size, size = download_sym_file(auth_token, url)

            if size is None:
                continue

            click.echo([module, debug_id, debug_filename, url, size, compressed_size])
            csvwriter.writerow([module, debug_id, debug_filename, url, size, compressed_size])

            current_num += 1

    click.echo("Done!")


if __name__ == "__main__":
    download_symbols_by_name()
