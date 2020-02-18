
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
	typefill doc --spm --spm-module TypeFill

.PHONY: single
single: 
	typefill doc --single-file example/sample.swift --ibaction --iboutlet -- ${PWD}/Sources/TestingData/sample.swift

.PHONY: spm
spm: 
	sourcekitten doc --spm --spm-module TestingData
	#  -- -Xswiftc -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
	# swift -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
	#  -I. -L. -lOnlinePlayground -lCryptoSwift 

.PHONY: kittenSingle
kittenSingle:
	sourcekitten doc --single-file example/sample.swift -- ${PWD}/Sources/TestingData/sample.swift

.PHONY: open
open:
	sourcekitten request --yaml example/open.yml

.PHONY: cursor
cursor:
	sourcekitten request --yaml example/cursor.yml

	# doc --spm --spm-module TypeFill
	# doc -- -workspace /Users/yume/git/itraveltaichungios/BusApp.xcworkspace -scheme CY_BusApp