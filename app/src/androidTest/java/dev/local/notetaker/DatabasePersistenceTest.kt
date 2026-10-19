package dev.local.notetaker

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import android.content.Context
import dev.local.notetaker.data.Note
import dev.local.notetaker.data.NotesDatabase
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import java.util.UUID

@RunWith(AndroidJUnit4::class)
class DatabasePersistenceTest {
    @Test fun notesSurviveDatabaseCloseAndReopenAndSortDeterministically() = runTest {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val name = "persistence-${UUID.randomUUID()}.db"
        fun open() = Room.databaseBuilder(context, NotesDatabase::class.java, name).build()
        val expected = listOf(
            Note("newest", "Newest", "Line one\n世界 📝", 20),
            Note("a", "Tie A", "", 10),
            Note("b", "Tie B", "Body", 10),
        )
        try {
            val first = open()
            try { expected.reversed().forEach { first.notes().save(it) } } finally { first.close() }
            val reopened = open()
            try {
                assertEquals(expected, reopened.notes().observeNotes().first())
                val edited = expected[0].copy(body = "Replaced")
                reopened.notes().save(edited)
                assertEquals(3, reopened.notes().observeNotes().first().size)
                assertEquals(edited, reopened.notes().observeNotes().first().first())
            } finally { reopened.close() }
        } finally { context.deleteDatabase(name) }
    }
}
