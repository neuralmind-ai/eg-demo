package dev.local.notetaker.ui

import dev.local.notetaker.data.Note
import dev.local.notetaker.data.NotesRepository
import java.io.IOException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class NotesViewModelTest {
    private val dispatcher = StandardTestDispatcher()
    @Before fun setup() { Dispatchers.setMain(dispatcher) }
    @After fun tearDown() { Dispatchers.resetMain() }

    @Test fun successfulSaveUsesEditedContentAndReportsDurability() = runTest(dispatcher) {
        val repo = FakeRepository()
        val model = NotesViewModel(repo, now = { 42L }, newId = { "note-1" })
        model.create()
        model.edit("Title", "Hello\n世界 📝")
        model.save()
        assertTrue(model.editor.value!!.saving)
        advanceUntilIdle()
        assertEquals(Note("note-1", "Title", "Hello\n世界 📝", 42), repo.saved.single())
        assertFalse(model.editor.value!!.dirty)
        assertFalse(model.editor.value!!.saving)
    }

    @Test fun failurePreservesDraftAndAllowsRetry() = runTest(dispatcher) {
        val repo = FakeRepository().apply { fail = true }
        val model = NotesViewModel(repo)
        model.create()
        model.edit("Keep me", "Draft")
        model.save()
        advanceUntilIdle()
        assertTrue(model.editor.value!!.saveFailed)
        assertTrue(model.editor.value!!.dirty)
        assertEquals("Draft", model.editor.value!!.note.body)
        repo.fail = false
        model.save()
        advanceUntilIdle()
        assertFalse(model.editor.value!!.saveFailed)
        assertFalse(model.editor.value!!.dirty)
    }

    @Test fun pendingSaveCannotBeDuplicatedOrOverwrittenByEditing() = runTest(dispatcher) {
        val gate = CompletableDeferred<Unit>()
        val repo = FakeRepository().apply { pending = gate }
        val model = NotesViewModel(repo)
        model.create()
        model.edit("Snapshot", "Original")
        model.save()
        model.edit("Later", "Changed")
        model.save()
        model.close()
        assertNotNull(model.editor.value)
        gate.complete(Unit)
        advanceUntilIdle()
        assertEquals(1, repo.saved.size)
        assertEquals("Original", repo.saved.single().body)
    }

    @Test fun editingExistingNoteRetainsIdentity() = runTest(dispatcher) {
        val repo = FakeRepository()
        val model = NotesViewModel(repo)
        model.open(Note("existing", "Old", "Body", 1))
        model.edit("New", "Body")
        model.save()
        advanceUntilIdle()
        assertEquals("existing", repo.saved.single().id)
    }

    private class FakeRepository : NotesRepository {
        override val notes = MutableStateFlow<List<Note>>(emptyList())
        val saved = mutableListOf<Note>()
        var fail = false
        var pending: CompletableDeferred<Unit>? = null
        override suspend fun save(note: Note) {
            pending?.await()
            if (fail) throw IOException("Simulated storage failure")
            saved += note
        }
    }
}
