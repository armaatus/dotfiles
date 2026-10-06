# Risk tier of a PR from its changed files: DEEP, SKIM or TRUST.
# Input: {files: [{path, additions, deletions}], changedFiles?}. Output: {tier, reason}.
# changedFiles is the PR's real file count; GitHub returns at most 100 files per query.

def generated:
  test("(^|/)(uv\\.lock|package-lock\\.json|pnpm-lock\\.yaml|yarn\\.lock)$|(^|/)schema-[^/]*\\.json$|^frontend/src/types/generated/|routeTree\\.gen\\.ts$");

# Files that can't break production on their own.
def trusted:
  generated
  or test("^docs/|\\.md$|^locale/|/locales/|(^|/)(pyproject\\.toml|package\\.json)$")
  or test("(^|/)tests?/|(^|/)test_[^/]*\\.py$|_test\\.py$|\\.(test|spec)\\.[jt]sx?$|^e2e/");

def deep_reasons:
  [ (select(test("/migrations/")) | "migration"),
    (select(test("^brand_erp/(banking|bookkeeping|invoices)/|^brand_erp/(.*[/_])?(transactions?|payments?|ledgers?|vat|btw)([/_.]|$)")) | "money"),
    (select(test("^brand_erp/users/|security_middleware|(^|/)permissions\\.py$|(^|/)[a-z_]*auth(/|\\.py$)")) | "auth"),
    (select(test("^brand_erp/.+/api\\.py$")) | "cross-app api"),
    (select(test("^(infra|infrastructure|helm|secrets)/|^\\.github/workflows/|^config/settings")) | "infra") ];

def human_lines:
  if . >= 1000 then "\((. / 100 | floor) / 10)k lines" else "\(.) lines" end;

def tier_rank: {DEEP: 0, SKIM: 1, TRUST: 2}[.];

def tier:
  .files as $files
  | (.changedFiles // ($files | length)) as $changed
  | ([$files[] | select(.path | generated | not) | .additions + .deletions] | add // 0) as $lines
  | ([$files[].path | deep_reasons[]] | reduce .[] as $r ([]; if index([$r]) then . else . + [$r] end)) as $reasons
  | if $changed > ($files | length) then
      {tier: "DEEP", reason: "\($changed) files, too many to inspect"}
    elif ($files | length) > 0 and all($files[]; .path | trusted) then
      {tier: "TRUST", reason: "docs/tests/i18n/deps only"}
    elif ($reasons | length) > 0 or $lines > 800 then
      {tier: "DEEP", reason: (($reasons + (if $lines > 800 then [$lines | human_lines] else [] end)) | join(", "))}
    else
      {tier: "SKIM", reason: "\($lines | human_lines), \($files | length) files"}
    end;
