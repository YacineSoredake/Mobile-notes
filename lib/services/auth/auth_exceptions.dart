// Login exeptions 
class UserNotFoundAuthException implements Exception {}
class WrongPasswordAuthException implements Exception {}

// register exepcetions
class WeakPasswordAuthException implements Exception {}
class EmailAlreadyInUseAuthException implements Exception {} 
class InvalidEmailAuthException implements Exception {}

// generic exceptions
class GenericAuthException implements Exception {}
class UserNotLoggedInAuthException implements Exception {}

