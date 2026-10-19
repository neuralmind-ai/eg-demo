package dev.local.notetaker.data

import kotlinx.coroutines.flow.Flow

interface NotesRepository {
    val notes: Flow<List<Note>>
    suspend fun save(note: Note)
}

class RoomNotesRepository(private val dao: NoteDao) : NotesRepository {
    override val notes = dao.observeNotes()
    override suspend fun save(note: Note) = dao.save(note)
}
