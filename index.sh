#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: ./index.sh
#/
#/ Generate README.md index file with links to all reveal.js presentations
#/  


#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

output_dir=gh-pages
index_file="README.md"
#}}}

cd "${output_dir}"

cat > "${index_file}" << _EOF_
# Slides Linux

Dit is een overzicht van de slides voor de lessen van het opleidingsonderdeel Linux in het tweede modeltraject van de opleiding professionele bachelor toegepaste informatica aan [HOGENT](https://www.hogent.be/).

_EOF_

for presentation in *.html; do
  # Extract the <title> and remove HTML tags and whitespace
  title=$(grep -F '<title>' "${presentation}" | sed -E 's/<[^>]*>//g;s/^\s+//')

  # Print an ordered list with presentation title and link to the .html file
  printf -- '- [%s](%s)\n' "${title}" "${presentation}" >> "${index_file}"
done

printf '\nLaatste wijziging: %s\n' "$(date --utc --iso-8601=seconds)" >> "${index_file}"