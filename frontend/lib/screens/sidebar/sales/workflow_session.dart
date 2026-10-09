/// In-memory credential used only by Sales approval and conversion requests.
class SalesWorkflowSession {
  SalesWorkflowSession._();
  static String? token;
  static Map<String, String> get headers => token == null || token!.isEmpty
      ? const {}
      : {'Authorization': 'Bearer $token'};
}
