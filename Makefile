
.PHONY: proj
proj:
	swift package generate-xcodeproj
	open TypeFill.xcodeproj

.PHONY: release
release: 
	@swift build -c release

.PHONY: install
install: release
	@cp .build/release/typefill /usr/local/bin

.PHONY: self
self:
	typefill doc --spm --spm-module TypeFill

.PHONY: single
single: 
	typefill doc --single-file example/sample.swift -- /Users/yume/git/TypeFill/example/sample.swift

.PHONY: open
open:
	sourcekitten request --yaml example/open.yml

.PHONY: cursor
cursor:
	sourcekitten request --yaml example/cursor.yml