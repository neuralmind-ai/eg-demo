package dev.local.notetaker

import android.app.Application
import androidx.room.Room
import dev.local.notetaker.data.NotesDatabase
import dev.local.notetaker.data.RoomNotesRepository

class NotesApplication : Application() {
    private val database by lazy {
        Room.databaseBuilder(this, NotesDatabase::class.java, "notes.db").build()
    }
    val repository by lazy { RoomNotesRepository(database.notes()) }
}
