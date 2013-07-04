bork.sh:
	@echo '#!/bin/bash' > bork.sh
	@cat sources/* lib/* >> bork.sh
	@chmod +x bork.sh

reload:
	@rm bork.sh
	@make bork.sh

.PHONY: reload
