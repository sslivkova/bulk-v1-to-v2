# Bulk Tavern Card v1 to v2 Updater
It updates tavern cards from v1 to v2 in bulk

# Requirements
* [Perl](https://www.perl.org/get.html)
* [Libpng](https://metacpan.org/dist/Image-PNG-Libpng/view/lib/Image/PNG/Libpng.pod)

# Usage
`perl bulkV1toV2.pl [path to tavern cards] [path to output]`

If no source path is provided, it will default to '.' (current directory).

If no output path is provided, it will overwrite the source files.

# Example
`perl bulkV1toV2.pl ./v1cards ./v2cards`

