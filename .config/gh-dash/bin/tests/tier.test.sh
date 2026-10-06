#!/usr/bin/env bash
# Tests for lib/tier.jq. Run: bin/tests/tier.test.sh
set -uo pipefail

LIB="$(cd "$(dirname "$0")/../lib" && pwd)"
fails=0

f() { printf '{"path":"%s","additions":%d,"deletions":%d}' "$1" "$2" "${3:-0}"; }
pr() { local IFS=,; printf '{"files":[%s]}' "$*"; }

check() {
  local name=$1 input=$2 want_tier=$3 want_reason=$4
  local got
  got=$(jq -r -L "$LIB" 'include "tier"; tier | "\(.tier)\t\(.reason)"' <<<"$input")
  local tier=${got%%$'\t'*} reason=${got#*$'\t'}
  if [[ $tier != "$want_tier" || $reason != *"$want_reason"* ]]; then
    echo "FAIL $name: got [$tier] [$reason], want [$want_tier] containing [$want_reason]"
    fails=$((fails + 1))
  else
    echo "ok   $name"
  fi
}

check "migration is deep" \
  "$(pr "$(f brand_erp/invoices/migrations/0042_x.py 20)" "$(f brand_erp/invoices/models.py 10)")" \
  DEEP migration
check "money app is deep" \
  "$(pr "$(f brand_erp/banking/services.py 40 5)")" DEEP money
check "auth is deep" \
  "$(pr "$(f brand_erp/users/permissions.py 12)")" DEEP auth
check "cross-app api.py is deep" \
  "$(pr "$(f brand_erp/companies/api.py 8)")" DEEP "cross-app api"
check "infra is deep" \
  "$(pr "$(f infra/main.tf 30)" "$(f .github/workflows/ci.yml 2)")" DEEP infra
check "big feature is deep by size" \
  "$(pr "$(f frontend/src/features/x/Big.tsx 700 150)")" DEEP "850 lines"
check "several reasons are listed once each" \
  "$(pr "$(f brand_erp/banking/migrations/0001_a.py 5)" "$(f brand_erp/banking/migrations/0002_b.py 5)" "$(f brand_erp/banking/api.py 5)")" \
  DEEP "migration, money, cross-app api"
check "generated and lock files don't count toward size" \
  "$(pr "$(f uv.lock 5000)" "$(f frontend/src/types/generated/api.ts 3000)" "$(f schema-public.json 900)" "$(f frontend/src/features/x/A.tsx 40)")" \
  SKIM "40 lines"
check "normal feature is skim" \
  "$(pr "$(f frontend/src/features/x/A.tsx 120 30)" "$(f brand_erp/todos/views.py 60)")" SKIM "210 lines, 2 files"
check "docs only is trust" \
  "$(pr "$(f docs/features/x.md 300)" "$(f README.md 4)")" TRUST "docs/tests/i18n/deps only"
check "tests only is trust, even in a money app" \
  "$(pr "$(f brand_erp/banking/tests/test_sync.py 400)" "$(f frontend/src/features/x/A.test.tsx 50)" "$(f e2e/specs/x.spec.ts 30)")" \
  TRUST "only"
check "i18n and lockfile only is trust" \
  "$(pr "$(f locale/nl/LC_MESSAGES/django.po 200)" "$(f frontend/src/locales/nl.json 50)" "$(f uv.lock 900)")" TRUST "only"
check "one real file makes it not trust" \
  "$(pr "$(f docs/x.md 10)" "$(f brand_erp/todos/views.py 3)")" SKIM "13 lines"
check "size shows as k above 1000" \
  "$(pr "$(f frontend/src/features/x/A.tsx 1500 200)")" DEEP "1.7k lines"
check "empty file list is skim" '{"files":[]}' SKIM "0 lines"
check "money outside the money apps (transaction linking) is deep" \
  "$(pr "$(f brand_erp/admin_api/companies/transaction_links/services.py 40)")" DEEP money
check "vat code is money" \
  "$(pr "$(f brand_erp/admin_api/vat_return/views.py 10)")" DEEP money
check "vat inside a word is not money" \
  "$(pr "$(f brand_erp/companies/private_notes.py 10)")" SKIM "10 lines"
check "author in a file name is not auth" \
  "$(pr "$(f brand_erp/todos/author_utils.py 10)")" SKIM "10 lines"
check "an auth module is auth" \
  "$(pr "$(f brand_erp/platform/platform_auth/views.py 10)")" DEEP auth
check "platform email is not auth" \
  "$(pr "$(f brand_erp/platform/email/sender.py 10)")" SKIM "10 lines"
check "nested app api.py is cross-app api" \
  "$(pr "$(f brand_erp/uploads/receipts/api.py 10)")" DEEP "cross-app api"
check "dependency manifests only is trust" \
  "$(pr "$(f pyproject.toml 2 2)" "$(f frontend/package.json 3 3)" "$(f uv.lock 300)")" TRUST "only"
check "more files than fetched is deep" \
  '{"changedFiles":140,"files":[{"path":"frontend/src/a.tsx","additions":5,"deletions":0}]}' DEEP "140 files"
check "rank orders deep, skim, trust" \
  "$(pr "$(f docs/a.md 1)")" TRUST "only"
got=$(jq -rn -L "$LIB" 'include "tier"; ["TRUST","DEEP","SKIM"] | map(tier_rank) | join(",")')
[[ $got == "2,0,1" ]] && echo "ok   tier_rank" || { echo "FAIL tier_rank: $got"; fails=$((fails + 1)); }

if ((fails)); then echo "$fails failing"; exit 1; fi
echo "all passed"
