#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# bash 5 tilde-expands a literal ~ in the replacement back to $HOME; a variable keeps it literal on 3.2 and 5
tilde='~'
short_cwd="${cwd/#$HOME/$tilde}"

branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)

# Nerd Font characters (UTF-8 encoded)
SEP=$(printf '\xee\x82\xb1')          # U+E0B1 thin right-pointing arrow
BRANCH_ICON=$(printf '\xee\x82\xa0')  # U+E0A0 git branch

# Afterglow palette, 256-color approximations (no bold: the theme is flat/muted)
ESC=$'\033'
R="${ESC}[0m"
DIM="${ESC}[38;5;240m"
BLUE="${ESC}[38;5;67m"      # dir      #6c99bb
GREEN="${ESC}[38;5;107m"    # branch   #90a959
ORANGE="${ESC}[38;5;166m"   # model    #e87d3e
YELLOW="${ESC}[38;5;179m"   # warn     #e5b567
RED="${ESC}[38;5;131m"      # high     #ac4142
FG="${ESC}[38;5;252m"       # normal   #d0d0d0
GRAY="${ESC}[38;5;243m"     # quiet    #797979

DIM_SEP="${DIM}${SEP}${R}"

parts=()

# Segment 1: directory + git branch
dir_seg="${BLUE}${short_cwd}${R}"
[ -n "$branch" ] && dir_seg+=" ${GREEN}${BRANCH_ICON} ${branch}${R}"
parts+=("$dir_seg")

# Segment 2: model name
if [ -n "$model" ] && [ "$model" != "null" ]; then
  parts+=("${ORANGE}${model}${R}")
fi

# Segment 3: context usage (color-coded by threshold)
if [ -n "$used_pct" ]; then
  ctx_int=$(printf '%.0f' "$used_pct")
  if [ "$ctx_int" -ge 80 ]; then
    ctx_color="$RED"
  elif [ "$ctx_int" -ge 60 ]; then
    ctx_color="$YELLOW"
  else
    ctx_color="$FG"
  fi
  parts+=("${ctx_color}ctx ${ctx_int}%${R}")
fi

# Segment 4: rate limits (only shown when data is available), quiet gray until elevated
rate_out=""
rate_max=0
if [ -n "$five_h" ]; then
  v=$(printf '%.0f' "$five_h")
  rate_out+="5h:${v}%"
  [ "$v" -gt "$rate_max" ] && rate_max=$v
fi
if [ -n "$seven_d" ]; then
  v=$(printf '%.0f' "$seven_d")
  [ -n "$rate_out" ] && rate_out+=" "
  rate_out+="7d:${v}%"
  [ "$v" -gt "$rate_max" ] && rate_max=$v
fi
if [ -n "$rate_out" ]; then
  if [ "$rate_max" -ge 85 ]; then
    rate_color="$RED"
  elif [ "$rate_max" -ge 60 ]; then
    rate_color="$YELLOW"
  else
    rate_color="$GRAY"
  fi
  parts+=("${rate_color}${rate_out}${R}")
fi

# Join segments with dim thin-arrow separator
result=""
for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && result+=" ${DIM_SEP} "
  result+="${parts[$i]}"
done

printf "%s\n" "$result"
