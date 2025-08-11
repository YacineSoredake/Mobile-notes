import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/services/cloud/cloud_exception.dart';
import 'package:flutter_app/services/cloud/cloud_storage_const.dart';
import 'package:flutter_app/services/cloud/cloud_note.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> DeleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map(
        (event) => event.docs
            .map((doc) => CloudNote.fromSnapshot(doc))
            .where((note) => note.ownerUserId == ownerUserId),
      );

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((doc) {
              return CloudNote(
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName],
                text: doc.data()[textFieldName],
              );
            }),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({required String ownerUserId, required String text}) {
    notes.add({ownerUserIdFieldName: ownerUserId, textFieldName: 'text'});
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
