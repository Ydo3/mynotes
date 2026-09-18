class CloudStorageException implements Exception {
  const CloudStorageException();
}

//c in crud
class CouldNotCreateNoteException extends CloudStorageException {}

//r in crud
class CouldNotGetAllNotesException extends CloudStorageException {}

//u in crud
class CouldNotUpdateNoteException extends CloudStorageException {}

//d in crud
class CouldNotDeleteNoteException extends CloudStorageException {}
