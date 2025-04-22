#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"
BLUE="\033[0;34m"

BASE_REF="${BASE_REF:-main}"
STRICT_MODE="${STRICT_MODE:-false}"

echo "--------------------------------------------------------------------------"
echo ""
echo -e "$GREEN Checking for Co-authored-by lines in the last commits...$RESET"
echo -e "$GREEN Base reference branch: $BASE_REF$RESET"
echo -e "$GREEN Strict mode: $STRICT_MODE$RESET"
echo ""

set -e
git config --global --add safe.directory /github/workspace
git config --global core.pager cat

git fetch origin "$BASE_REF" --quiet
PREVIOUS_HEAD=$(git rev-parse origin/"$BASE_REF")
echo -e "$GREEN Previous head of $BASE_REF: $PREVIOUS_HEAD$RESET"

if [ -n "$GITHUB_REF" ]; then
    git fetch origin "$GITHUB_REF" --quiet
    CURRENT_HEAD=$(git rev-parse FETCH_HEAD)
    echo -e "$GREEN Current head (from GITHUB_REF): $CURRENT_HEAD$RESET"
else
    CURRENT_HEAD=$(git rev-parse HEAD)
    echo -e "$GREEN Current head: $CURRENT_HEAD$RESET"
fi

COMMITS=$(git log --pretty=format:"%H" "$PREVIOUS_HEAD".."$CURRENT_HEAD")

if [ -z "$COMMITS" ]; then
    echo -e "$RED No commits found between the previous head and the current head.$RESET"
    exit 0
fi

STATUS=0
COUNT=0

for COMMIT in $COMMITS; do
    MSG=$(git show -s --format=%B "$COMMIT")
    LINE_NUMBER=0

    while IFS= read -r LINE; do
        LINE_NUMBER=$((LINE_NUMBER + 1))
        # echo -e "$GREEN Checking line $LINE_NUMBER in commit $COMMIT: '$LINE'$RESET"

        if [[ "$LINE" == Co-authored-by:* || "$LINE" == Co-Authored-By:* ]]; then
            COUNT=$((COUNT + 1))
            # echo -e "$GREEN Checking Co-authored-by line in commit $COMMIT: '$LINE'$RESET"

            if [[ "$LINE" != Co-authored-by:* ]]; then
                echo -e "$RED Incorrect casing in line $LINE_NUMBER of $COMMIT: '$LINE'$RESET"
                STATUS=$((STATUS | 15))
                continue
            fi

            NAME_EMAIL=$(echo "$LINE" | sed -n 's/^Co-authored-by:[[:space:]]*//Ip')
            NAME=$(echo "$NAME_EMAIL" | sed -E 's/<.*>//')
            EMAIL=$(echo "$NAME_EMAIL" | grep -oE '<.*>' | tr -d '<>')

            if [[ -z "$EMAIL" ]]; then
                echo -e "$RED Missing email in line $LINE_NUMBER of $COMMIT: '$LINE'$RESET"
                STATUS=$((STATUS | 15))
                continue
            fi

            WORD_COUNT=$(echo "$NAME" | wc -w)
            if [[ "$WORD_COUNT" -lt 2 ]]; then
                echo -e "$YELLOW Single-word name in line $LINE_NUMBER of $COMMIT: '$NAME'$RESET"
                STATUS=$((STATUS | 7))
                continue
            fi

            if [[ "$EMAIL" == *"noreply.github.com"* ]]; then
                echo -e "$YELLOW GitHub noreply email in line $LINE_NUMBER of $COMMIT: '$EMAIL'$RESET"
                STATUS=$((STATUS | 7))
                continue
            fi
            echo -e "$GREEN Valid Co-authored-by line in $COMMIT: '$LINE'$RESET"
        fi
    done <<< "$MSG"
done

if [[ "$COUNT" -eq 0 ]]; then
    echo -e "$YELLOW No Co-authored-by lines found in the commits.$RESET"
    if [[ "$STRICT_MODE" == "true" ]]; then
        echo -e "$RED Strict mode is enabled. Please add Co-authored-by lines.$RESET"
        echo "--------------------------------------------------------------------------"
        exit 1
    else
        echo -e "$GREEN No issues found in the commits.$RESET"
        echo "--------------------------------------------------------------------------"
        exit 0
    fi
fi

echo -e "$GREEN Found $COUNT Co-authored-by lines in the commits.$RESET"

if [[ "$STRICT_MODE" == "true" && "$STATUS" -ne 0 ]]; then
    echo -e "$RED Strict mode is enabled. Formatting issues found.$RESET"
    echo "--------------------------------------------------------------------------"
    exit 1
elif [[ "$STATUS" -eq 0 ]]; then
    echo -e "$GREEN Co-authored-by lines verified.$RESET"
    echo "--------------------------------------------------------------------------"
else
    if [[ "$STATUS" -eq 15 ]]; then
        echo -e "$RED Major formatting issues found in Co-authored-by lines.$RESET"
    elif [[ "$STATUS" -eq 7 ]]; then
        echo -e "$YELLOW Some minor formatting issues found in Co-authored-by lines.$RESET"
    else
        echo -e "$BLUE You should not have reached here idk how you did it but you did. Please report this issue.$RESET"
    fi
    echo "--------------------------------------------------------------------------"
    exit 1
fi

echo "--------------------------------------------------------------------------"