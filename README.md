# mget (Multi-stream get) utility for fast web content downloading

## Usage

`mget <URL> [output file name]`

This software depends on `curl` utility.

`mget` check for content length and make several parallel streams, which download parts of target content. By default target file is devided into 100Mb chunks.

In test I downloaded 1.7Gb ISO file in approximately one minute, while in single mode it was doanloaded in six-seven minutes.

## Disclaimer

There is no error control at all. Please check finsl data integrity with checksums.
