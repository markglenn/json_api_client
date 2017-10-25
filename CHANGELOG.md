# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Added `Request.header/3` method
- Renamed client_name to user_agent_suffix
- Use package name as prefix instead of ExApiClient.
- set Mix.Project.config[:app] as a default value for user_agent_suffix
- added possibility to configure HTTP Client Backend
- Added middleware architecture
- Added `Fuse` and `StatsTracker` middlewares
- Bug fix when path generation is a post request

## [1.0.0] - 2017-10-17
### Added
- `Request.path/2` added

## [0.5.2] - 2017-10-17
### Fixed
- Fixed package config so that primary documentation link in hex.pm works

## [0.5.1] - 2017-10-17
### Fixed
- Removed `organization` from mix.exs so that package will be public
- Removed Unused dependencies from mix.exs

## [0.5.0] - 2017-10-17
### Added
- This CHANGELOG.md
- A good bit of docuemtnation

### Removed
- The `RequestError` struct lost the `reson` attribute. We now just use `message`


[Unreleased]: https://github.com/decisiv/json_api_client/compare/0.5.1...HEAD
[1.0.0]: https://github.com/decisiv/json_api_client/compare/0.5.2...1.0.0
[0.5.2]: https://github.com/decisiv/json_api_client/compare/0.5.1...0.5.2
[0.5.1]: https://github.com/decisiv/json_api_client/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/decisiv/json_api_client/compare/0.4.0...0.5.0
