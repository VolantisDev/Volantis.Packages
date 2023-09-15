class GithubPackageSource extends PackageSourceBase {
    _baseUrl := "https://github.com/"
    _urlSuffix := ".git"

    __New(baseUrl := "") {
        if (baseUrl != "") {
            this._baseUrl := baseUrl
        }
    }

    _GetUrl(sourceInfo) {
        locationStr := sourceInfo["location"]
        suffixLen := StrLen(this._urlSuffix)

        if (StrLen(locationStr) < suffixLen || SubStr(locationStr, -suffixLen) != this._urlSuffix) {
            locationStr .= this._urlSuffix
        }

        return this.baseUrl . locationStr
    }
}