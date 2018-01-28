STATUS_OK=0
STATUS_FAILED=1
STATUS_MISSING=10
STATUS_OUTDATED=11
STATUS_PARTIAL=12
STATUS_MISMATCH_UPGRADE=13
STATUS_MISMATCH_CLOBBER=14
STATUS_CONFLICT_UPGRADE=20
STATUS_CONFLICT_CLOBBER=21
STATUS_CONFLICT_HALT=25
STATUS_BAD_ARGUMENTS=30
STATUS_FAILED_ARGUMENTS=31
STATUS_FAILED_ARGUMENT_PRECONDITION=32
STATUS_FAILED_PRECONDITION=33
STATUS_UNSUPPORTED_PLATFORM=34

_status_for () {
  case "$1" in
    $STATUS_OK) echo "ok" ;;
    $STATUS_FAILED) echo "failed" ;;
    $STATUS_MISSING) echo "missing" ;;
    $STATUS_OUTDATED) echo "outdated" ;;
    $STATUS_PARTIAL) echo "partial" ;;
    $STATUS_MISMATCH_UPGRADE) echo "mismatch (upgradable)" ;;
    $STATUS_MISMATCH_CLOBBER) echo "mismatch (clobber required)" ;;
    $STATUS_CONFLICT_UPGRADE) echo "conflict (upgradable)" ;;
    $STATUS_CONFLICT_CLOBBER) echo "conflict (clobber required)" ;;
    $STATUS_CONFLICT_HALT) echo "conflict (unresolvable)" ;;
    $STATUS_BAD_ARGUMENT) echo "error (bad arguments)" ;;
    $STATUS_FAILED_ARGUMENTS) echo "error (failed arguments)" ;;
    $STATUS_FAILED_ARGUMENT_PRECONDITION) echo "error (failed argument precondition)" ;;
    $STATUS_FAILED_PRECONDITION) echo "error (failed precondition)" ;;
    $STATUS_UNSUPPORTED_PLATFORM) echo "error (unsupported platform $baking_platform)" ;;
    *)    echo "unknown status: $1" ;;
  esac
}
