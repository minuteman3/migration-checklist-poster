#!/usr/bin/env bash
set -x

GITHUB_TOKEN=$1

if [ -z "${GITHUB_TOKEN}" ]; then
  >&2 echo "Set the GITHUB_TOKEN input variable."
  exit 1
fi

get_pr_files(){
  pr_num=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.number)
  request_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${pr_num}/files"
  auth_header="Authorization: token $GITHUB_TOKEN"
  changed_files=$(curl -s -H "$auth_header" -X GET -G ${request_url})
  echo ${changed_files}
}

have_posted_comment_before() {
  pr_num=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.number)
  request_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${pr_num}/comments"
  auth_header="Authorization: token $GITHUB_TOKEN"
  have_posted=$(curl -s -H "$auth_header" -X GET -G ${request_url} | jq -r '.[] | select(.body | contains (":paperclip: It looks like you are trying to merge a")) | any?')
  echo ${have_posted}
}

post_pr_comment() {
  local msg=$1
  payload=$(echo '{}' | jq --arg body "${msg}" '.body = $body')
  request_url=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
  curl -s -S \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "${payload}" \
    "${request_url}" > /dev/null
}

checklist_filename() {
  local repo_specific_checklist="/checklists/${GITHUB_REPOSITORY}.md"
  if [[ -f "${repo_specific_checklist}" ]]
  then
    echo "${repo_specific_checklist}"
  else
	echo "/checklists/default.md"
  fi
}

main() {
  changed_files=$(get_pr_files)
  any_migration_files=$(echo $changed_files | jq -r 'map( select(.filename | contains("db/migrate")) ) | any?')
  
  have_posted=$(have_posted_comment_before)
  checklist="$(checklist_filename)"

  if [[ $have_posted ]]
  then
    exit 0
  fi

  if [[ $any_migration_files == "true" ]]
  then
    post_pr_comment "$(cat ${checklist})"
  fi
}

main "$@"
