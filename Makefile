bork:
	@echo '#!/bin/bash' > bork
	@cat sources/* lib/* >> bork
	@chmod +x bork

reload:
	@rm bork
	@make bork

test:
	@bats test/

.PHONY: reload test
