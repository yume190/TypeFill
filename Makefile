
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

.PHONY: clear
clear: 
	@rm /usr/local/bin/typefill

.PHONY: clearAll
clearAll: clear
	@rm -Rf .build

.PHONY: self
self:
	typefill doc --ibaction --ibaction --objc --spm --spm-module TestingData

.PHONY: single
single: 
	typefill doc --single-file Sources/TestingData/sample.swift --ibaction --iboutlet -- ${PWD}/Sources/TestingData/sample.swift
	# typefill single --filePath "/Users/yume/git/yume/TypeFill/Sources/TestingData/sample.swift" -- -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk
	# /Users/yume/git/yume/TypeFill/Sources/TestingData/sample.swift

.PHONY: spm
spm: 
	sourcekitten doc --spm --spm-module TestingData
	#  -- -Xswiftc -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
	# swift -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
	#  -I. -L. -lOnlinePlayground -lCryptoSwift 

.PHONY: kittenSingle
kittenSingle:
	sourcekitten doc --single-file ${PWD}/Sources/TestingData/sample.swift -- ${PWD}/Sources/TestingData/sample.swift

.PHONY: open
open:
	sourcekitten request --yaml Sources/TestingData/open.yml

.PHONY: cursor
cursor:
	sourcekitten request --yaml Sources/TestingData/cursor.yml

doc:
	sourcekitten request --yaml Sources/TestingData/doc.yml

	# doc --spm --spm-module TypeFill

tangram:
	typefill doc --typefill -- -workspace /Users/yume/git/work/05_Tangram/Tangran-iOS/Tangran-iOS/Tangran-iOS.xcworkspace -scheme Tangran-iOS

index:
	mkdir -p Sources/TestingData/Index
	swiftc Sources/TestingData/sample.swift -index-store-path Sources/TestingData/Index -o Sources/TestingData/sample.o
	# /Users/yume/git/yume/TypeFill/Sources/TestingData/Index

index2:
	index-dump-tool print-record --index-store-path Sources/TestingData/Index > dump.txt


open1:
	sourcekitten request --yaml " \
		key.request: source.request.editor.open \
		key.name: ${PWD}/Sources/TestingData/sample.swift \
		key.sourcefile: ${PWD}/Sources/TestingData/sample.swift \
		"