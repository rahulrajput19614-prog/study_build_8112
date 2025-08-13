Future<void> _sendToAI(String prompt) async {
  if (prompt.trim().isEmpty) return;

  _addUserMessage(prompt);
  setState(() => _loading = true);
  _controller.clear();

  try {
    final uri = Uri.parse('https://study-backend.onrender.com/solve-doubt');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'question': prompt});

    final resp = await http.post(uri, headers: headers, body: body);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body);
      final reply = data['answer'] ?? 'No response';
      setState(() => _loading = false);
      _addSystemMessage(reply.trim());
    } else {
      setState(() => _loading = false);
      String msg = 'AI error: ${resp.statusCode}';
      try {
        final err = jsonDecode(resp.body);
        if (err is Map && err['error'] is String) {
          msg = 'AI error: ${err['error']}';
        }
      } catch (_) {}
      _addSystemMessage(msg, isError: true);
    }
  } catch (e) {
    setState(() => _loading = false);
    _addSystemMessage('Network error: $e', isError: true);
  }
}
