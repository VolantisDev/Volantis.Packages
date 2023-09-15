class PackageSourceBase {
    GetUrl(sourceInfo) {
        if (!sourceInfo) {
            throw DataException("Package source info cannot be empty.")
        }

        if (Type(sourceInfo) == "String") {
            sourceInfo := Map("location", sourceInfo)
        }

        return this._GetUrl(sourceInfo)
    }

    _GetUrl(sourceInfo) {
        throw MethodNotImplementedException("PackageSourceBase", "_GetUrl")
    }
}
