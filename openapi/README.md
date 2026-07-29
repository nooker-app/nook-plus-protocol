# OpenAPI

`openapi.yaml` is the single canonical specification for the service API.
Nothing copies or symlinks it.

`openapi-generator-config.yaml` configures Apple's
[swift-openapi-generator](https://github.com/apple/swift-openapi-generator),
which runs as a SwiftPM build plugin over this directory. The Swift types
and client are therefore produced at build time and are **not** committed —
they cannot drift from the specification, because they do not exist
independently of it.

Go types are generated differently: `make generate` writes them into
`generated/go/`, and CI fails if the committed output is stale. Both
approaches guarantee the same property; see `AGENTS.md`.

To use the generated client:

```swift
import NookPlusServiceAPI
```

The generated client stops at the transport abstraction. A URLSession
transport and any authentication middleware belong to the consuming
application, not here.
