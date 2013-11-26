bork:
	@bin/build.sh > bork
	@chmod +x bork

clean:
	@rm bork

test:
	@bats test/

.PHONY: clean test
