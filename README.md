# ValidationCore

Core functionality for validating EHN health certificates from QR codes. Suitable QR codes can be generated using https://dev.a-sit.at/certservice

Implements a very basic validation chain:

Decode Base45-encoded QR code
Remove scheme prefix
Decompress with ZLib
Verify COSE signature


## Demo Application Code

A demo application using this package can be found at [hcert-app-swift](https://github.com/ehn-digital-green-development/hcert-app-swift)

## Dependencies

The core functionality depends on [https://github.com/ehn-digital-green-development/base45-swift](https://github.com/ehn-digital-green-development/base45-swift), [https://github.com/unrelentingtech/SwiftCBOR](https://github.com/unrelentingtech/SwiftCBOR) and [https://github.com/1024jp/GzipSwift](https://github.com/1024jp/GzipSwift).
All dependencies are resolved as Swift Packages.
