class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C
class NotCreateNoteException extends CloudStorageException {}
// R
class CouldNotGetAllNotesException extends CloudStorageException {}
// U
class CouldNotUpdateNoteException extends CloudStorageException {}
// D
class CouldNotDeleteNoteException extends CloudStorageException {}