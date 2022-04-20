# Weather App

## Tech Stack
- Xcode 13.2.1
- SwiftUI
- Combine
- XCTest
- SF Symbols

## Schemes
- App Online - Use to connect with MetaWeather API
- App Offline - Use application offline (mechanism faking responses using JSON files in Project)
- Unit Tests - Use for testing. It contains a mechanism for faking responses (the same which is used in App Offline)

## Configurations
Using one of 3 build configurations (and associated to them *.xcconfig* files):
- Debug
- Offline
- Release

## Architecture
Application is quite simple so it doesn't require complex architecture. Using simplified version of Onion-like architecture. It consists of:
- Data e.g. *Repositories*
- Domain e.g. *UseCases*
- Presentation e.g. *View*, *ViewModels*

## Possible improvements

What could be improved:

### Automation
It's always good to have some kind of *bootstrap.sh* which would take advantage of such tools like *Tuist*, *XcodeGen* etc. to generate project files, assets, translations. It could be also used for registering *.xctemplate* files to autogenerate code which is repeating.

### Modularisation
It's small app but if it would grow up a lot, it could be modularised using frameworks or packages from Swift Package Manager - *XcodeGen* could be used for that.

### Code generation
Sourcery could be used for auto-creation of the code.

### Tests
It would be very useful to configure **Snapshot and UI Tests** to the application which could be treated as Smoke Tests.

### CI / CD
For code reviews and deployment e.g. fastlane + Bitrise.
