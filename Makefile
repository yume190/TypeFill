VERSION = 0.1.9

include SourceKitten.mk
include TypeFill.mk

# https://forums.swift.org/t/indexstoredb-support-error/28253
.PHONY: proj
proj:
	swift package generate-xcodeproj --xcconfig-overrides overrides.xcconfig
	open TypeFill.xcodeproj

.PHONY: release
release: 
	@swift build -c release

.PHONY: install
install: release
	@cp .build/release/typefill /usr/local/bin

.PHONY: clear
clear: 
	@rm /usr/local/bin/typefill

.PHONY: clearAll
clearAll: clear
	@rm -Rf .build

.PHONY: githubRelease
githubRelease:
	sed -i '' 's|\(version: "\)\(.*\)\("\)|\1$(VERSION)\3|' Sources/TypeFill/Command/TypeFill.swift

	git add Sources/TypeFill/Command/TypeFill.swift
	git add Makefile

	git commit -m "Update to $(VERSION)"
	git tag $(VERSION)





# other
index:
	mkdir -p TestingData/Index
	swiftc TestingData/sample.swift.data -index-store-path TestingData/Index -o TestingData/sample.o
	# /Users/yume/git/yume/TypeFill/TestingData/Index

index2:
	index-dump-tool print-record --index-store-path TestingData/Index > dump.txt

# project --project /Users/yume/git/yume/TypeFill/TypeFill.xcodeproj --scheme TypeFill -v --skipBuild

# spm --moduleName TypeFill --path /Users/yume/git/yume/TypeFill -v --print --skipBuild
