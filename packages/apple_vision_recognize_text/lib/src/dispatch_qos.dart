/// Quality-of-service classes that specify the priorities for executing tasks.
enum AppleVisionDispatchQoS {
  /// The quality-of-service class for user-interactive tasks, such as animations, event handling, or updating your app's user interface.
  userInteractive,

  /// The quality-of-service class for tasks that prevent the user from actively using your app.
  userInitiated,

  /// The default quality-of-service class.
  normal, // default but can't use 'default' as a name

  /// The quality-of-service class for tasks that the user does not track actively.
  utility,

  /// The quality-of-service class for maintenance or cleanup tasks that you create.
  background,

  /// The absence of a quality-of-service class.
  unspecified,
  ;

  String get name {
    switch (this) {
      case AppleVisionDispatchQoS.userInteractive:
        return 'userInteractive';
      case AppleVisionDispatchQoS.userInitiated:
        return 'userInitiated';
      case AppleVisionDispatchQoS.normal:
        return 'default'; // return to default
      case AppleVisionDispatchQoS.utility:
        return 'utility';
      case AppleVisionDispatchQoS.background:
        return 'background';
      case AppleVisionDispatchQoS.unspecified:
        return 'unspecified';
    }
  }
}
