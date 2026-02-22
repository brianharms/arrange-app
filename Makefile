.PHONY: generate build run clean

generate:
	xcodegen generate

build: generate
	xattr -cr Arrange/
	xcodebuild build -project Arrange.xcodeproj -scheme Arrange -configuration Debug -derivedDataPath build ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
	xattr -cr build/Build/Products/Debug/Arrange.app
	codesign --force --sign - --entitlements Arrange/Resources/Arrange.entitlements --deep build/Build/Products/Debug/Arrange.app

run: build
	open build/Build/Products/Debug/Arrange.app

clean:
	rm -rf build Arrange.xcodeproj
