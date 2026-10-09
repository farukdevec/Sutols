/// Gates asynchronous model selection without retaining model URLs or tokens.
/// A changed scope invalidates pending work even if the user later returns.
class LatestModelSelectionRequest {
  int _revision = 0;
  Object? _scope;

  int begin(Object scope) {
    _scope = scope;
    return ++_revision;
  }

  void observe(Object scope) {
    if (_scope != null && _scope != scope) invalidate();
  }

  bool accepts(int revision, Object scope) =>
      revision == _revision && _scope == scope;

  void invalidate() {
    _revision++;
    _scope = null;
  }
}
