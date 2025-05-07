.PHONY: test install lint-fix release check_clean

install:
	bundle install

lint-fix:
	bundle exec standardrb --fix

test:
	 bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))

check_clean:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "❌ Uncommitted changes found. Please commit or stash them first."; \
		exit 1; \
	fi

release: check_clean
	git add .
	git commit -am "Build new release assets"
	gem bump -t -v $(filter-out $@,$(MAKECMDGOALS))
	gem release -p -g

%:
	@:
