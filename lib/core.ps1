function fullpath($path) {
	$executionContext.sessionState.path.getUnresolvedProviderPathFromPSPath($path)
}