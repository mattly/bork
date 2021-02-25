#!/usr/bin/env bats

. test/helpers.sh

filesection () { . $BORK_SOURCE_DIR/types/filesection.sh "$@"; }
baking_responder () { "$@"; }

setup () {
  sourcefile=$(mktemp -t bork_test_filesection.XXXXXX)
  targetfile=$(mktemp -t bork_test_filesection.XXXXXX)
}

teardown () {
  rm $sourcefile $targetfile
}

@test "filesection status: returns FAILED_ARGUMENTS when source file is missing" {
  run filesection status targetfile sourcefile
  [ "$status" -eq $STATUS_FAILED_ARGUMENTS ]
}

@test "filesection status: returns MISSING when target is missing" {
  cat <<SOURCE > $sourcefile
source
SOURCE

  run filesection status doesnt_exist $sourcefile --start=start --end=end 
  [ "$status" -eq $STATUS_MISSING ]
}

@test "filesection status: returns MISSING when target is missing the section" {
  cat <<SOURCE > $sourcefile
source
SOURCE

  cat <<TARGET > $targetfile
target
TARGET

  run filesection status $targetfile $sourcefile --start=start --end=end 
  [ "$status" -eq $STATUS_MISSING ]
}

@test "filesection status: returns CONFLICT_UPGRADE when contents don't match" {
  cat <<SOURCE > $sourcefile
source
SOURCE

  cat <<TARGET > $targetfile
target
start
no_match
end
TARGET

  run filesection status $targetfile $sourcefile --start=start --end=end 
  [ "$status" -eq $STATUS_CONFLICT_UPGRADE ]
}

@test "filesection status: returns 0 when contents match" {
  cat <<SOURCE > $sourcefile
source
SOURCE

  cat <<TARGET > $targetfile
target
start
source
end
TARGET

  run filesection status $targetfile $sourcefile --start=start --end=end
  echo $output

  [ "$status" -eq 0 ]
}

@test "filesection install: works when contents are empty" {
  cat <<SOURCE > $sourcefile
source

SOURCE

  cat <<TARGET > $targetfile
target
start
end

TARGET

  run filesection install $targetfile $sourcefile --start=start --end=end 
  [ "$status" -eq 0 ]

  diff $targetfile - <<EXPECTED
target
start
source

end

EXPECTED

}


@test "filesection install: works when contents don't match" {
  cat <<SOURCE > $sourcefile
source
SOURCE

  cat <<TARGET > $targetfile
target
start
no_match
end
TARGET

  run filesection install $targetfile $sourcefile --start=start --end=end 
  [ "$status" -eq 0 ]

  diff $targetfile - <<EXPECTED
target
start
source
end
EXPECTED

}

@test "filesection install: ifmissing=append" {
  cat <<SOURCE > $sourcefile
source
SOURCE

  cat <<TARGET > $targetfile
target
TARGET

  run filesection install $targetfile $sourcefile --start=start --end=end --ifmissing=append
  [ "$status" -eq 0 ]

  diff $targetfile - <<EXPECTED
target
start
source
end
EXPECTED

}

@test "filesection install: ifmissing=prepend" {
  cat <<SOURCE > $sourcefile
source
SOURCE

  cat <<TARGET > $targetfile

target

TARGET

  run filesection install $targetfile $sourcefile --start=start --end=end --ifmissing=prepend
  [ "$status" -eq 0 ]

  diff $targetfile - <<EXPECTED
start
source
end

target

EXPECTED

}

