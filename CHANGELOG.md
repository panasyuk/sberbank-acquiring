# Changelog

## 1.0.0 - 2020-04-05
### Changed
- HTTP request method from `GET` to `POST` 

## 0.2.1 - 2019-01-29
### Added
- Reduced request checksum validation API with `AbstractChecksumValidator#valid?`

## 0.2.0 - 2019-01-27
### Added
- Changelog
- Asymmetric key request checksum validation
- `AbstractChecksumValidator`

### Changed
- Inherited `SymmetricKeyChecksumValidator` and `AsymmetricKeyChecksumValidator` from `AbstractChecksumValidator`

## 0.1.0 - 2018-12-10
### Added
- Running key (documented) requests against remote API
- Running any requests against remote API
- Symmetric key request checksum validation
- Test and Production environments support