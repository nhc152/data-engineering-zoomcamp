#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-logs/sample_pipeline.log}"

echo "Log file: ${LOG_FILE}"
echo
echo "Recent errors:"
grep -n "ERROR" "${LOG_FILE}" || true
echo
echo "Rows by status keyword:"
awk '{print $3}' "${LOG_FILE}" | sort | uniq -c

