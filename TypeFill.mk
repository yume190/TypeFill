
.PHONY: self
self:
	typefill doc --ibaction --ibaction --objc --spm --spm-module TestingData

.PHONY: single
single: 
	typefill single -v --print --filePath "${PWD}/TestingData/sample.swift" --sdk macosx

.PHONY: spm
spm: 
	typefill spm -v --moduleName TypeFillKit
	
.PHONY: xcode
xcode:
	typefill project --project ${PWD}/TypeFill.xcodeproj --scheme TypeFill -v --skipBuild
