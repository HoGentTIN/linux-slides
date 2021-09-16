#! /bin/sh
# Based on @zporter's publish script.
# See https://zachporter.dev/posts/publishing-hugo-with-github-actions/

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset

# Output directory
output_dir=gh-pages

# Exit if there are local changes
if [ "$(git status -s)" ]; then
  printf 'Changes detected in working directory. Commit them before proceeding.\n'
  exit 1
fi

printf 'Deleting old publication\n'
rm -rf "${output_dir}"
mkdir "${output_dir}"
git worktree prune
rm -rf ".git/worktrees/${output_dir}"

printf 'Fetch gh-pages branch\n'
git fetch origin gh-pages

printf 'Checking out gh-pages branch\n'
git worktree add -B gh-pages ${output_dir} origin/gh-pages

printf 'Running make to generate new version\n'
make all    # Generate slides
./index.sh  # Create index page

printf 'Updating gh-pages branch\n'
cd "${output_dir}" \
  && git add --all \
  && git commit -m "Publishing to gh-pages (${0}) at $(date --utc --iso-8601=seconds)"

printf 'Pushing to Github\n'
git push "${REPOSITORY:-origin}" gh-pages
