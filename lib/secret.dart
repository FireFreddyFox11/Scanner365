class Secret {
  final String username;
  final String password;
  final String url;
  final String apiKey;

  Secret({
    required this.username,
    required this.password,
    required this.url,
    required this.apiKey,
  });

  factory Secret.fromJson(Map<String, dynamic> json) {
    return Secret(
      username: json['username'],
      password: json['password'],
      url: json['url'],
      apiKey: json['apiKey'],
    );
  }
}
