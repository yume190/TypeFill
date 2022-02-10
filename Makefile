VERSION = 0.2.6

include SourceKitten.mk
include TypeFill.mk

# https://forums.swift.org/t/indexstoredb-support-error/28253
.PHONY: proj
proj:
	swift package generate-xcodeproj --xcconfig-overrides overrides.xcconfig
	open TypeFill.xcodeproj

.PHONY: build
build: 
	swift build

.PHONY: test
test: build
	@swift test -v 2>&1 | xcpretty

.PHONY: fillSelf
fillSelf: build
	typefill spm --module Cursor -v --skipBuild
	typefill spm --module DerivedPath -v --skipBuild
	typefill spm --module LeakDetect -v --skipBuild
	typefill spm --module LeakDetectExtension -v --skipBuild
	typefill spm --module TypeFill -v --skipBuild
	typefill spm --module TypeFillKit -v --skipBuild
	typefill spm --module SwiftLeakCheck -v --skipBuild
	

.PHONY: release
release: 
	@swift build -c release

.PHONY: install
install: release
	@cp .build/release/typefill /usr/local/bin
	@cp .build/release/LeakDetect /usr/local/bin

.PHONY: clear
clear: 
	@rm /usr/local/bin/typefill

.PHONY: clearAll
clearAll: clear
	@rm -Rf .build

.PHONY: githubRelease xcframework
githubRelease:
	sed -i '' 's|\(version: "\)\(.*\)\("\)|\1$(VERSION)\3|' Sources/TypeFill/Command/TypeFill.swift
	sed -i '' 's|\(version: "\)\(.*\)\("\)|\1$(VERSION)\3|' Sources/LeakDetect/main.swift

	sed -i '' 's|\(let checksum = "\)\(.*\)\("\)|\1`swift package compute-checksum TypeFillKit.zip`\3|' Package.swift
	sed -i '' 's|\(let binaryURL = "\)\(.*\)\("\)|\1https://github.com/yume190/TypeFill/releases/download/$(VERSION)/TypeFillKit.xcframework.zip\3|' Package.swift

	git add Sources/TypeFill/Command/TypeFill.swift
	git add Sources/LeakDetect/main.swift
	git add Makefile

	git commit -m "Update to $(VERSION)"
	git tag $(VERSION)
	git push origin $(VERSION)

# other
index:
	mkdir -p TestingData/Index
	swiftc TestingData/sample.swift.data -index-store-path TestingData/Index -o TestingData/sample.o
	# /Users/yume/git/yume/TypeFill/TestingData/Index

index2:
	index-dump-tool print-record --index-store-path TestingData/Index > dump.txt

graph:
	swift package show-dependencies --format dot | dot -Tsvg -o graph.svg

.PHONY: xcframework
xcframework:
	swift-create-xcframework --stack-evolution
	zip -r TypeFillKit.zip TypeFillKit.xcframework
# swift package compute-checksum TypeFillKit.zip



# project --project /Users/yume/git/yume/TypeFill/TypeFill.xcodeproj --scheme TypeFill -v --skipBuild

# spm --moduleName TypeFill --path /Users/yume/git/yume/TypeFill -v --print --skipBuild
