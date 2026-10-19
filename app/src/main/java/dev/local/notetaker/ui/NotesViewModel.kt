package dev.local.notetaker.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.local.notetaker.data.Note
import dev.local.notetaker.data.NotesRepository
import java.util.UUID
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class EditorState(
    val note: Note,
    val dirty: Boolean = false,
    val saving: Boolean = false,
    val saveFailed: Boolean = false,
)

class NotesViewModel(
    private val repository: NotesRepository,
    private val now: () -> Long = System::currentTimeMillis,
    private val newId: () -> String = { UUID.randomUUID().toString() },
) : ViewModel() {
    val notes = repository.notes.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())
    private val _editor = MutableStateFlow<EditorState?>(null)
    val editor = _editor.asStateFlow()

    fun create() { _editor.value = EditorState(Note(newId(), "", "", 0), dirty = true) }
    fun open(note: Note) { _editor.value = EditorState(note) }
    fun close() { if (_editor.value?.saving != true) _editor.value = null }
    fun edit(title: String, body: String) {
        val current = _editor.value ?: return
        if (current.saving) return
        _editor.value = current.copy(
            note = current.note.copy(title = title, body = body), dirty = true, saveFailed = false,
        )
    }
    fun save() {
        val current = _editor.value ?: return
        if (current.saving || !current.dirty) return
        val snapshot = current.note.copy(updatedAt = now())
        _editor.value = current.copy(saving = true, saveFailed = false)
        viewModelScope.launch {
            try {
                repository.save(snapshot)
                _editor.value = EditorState(snapshot)
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (_: Exception) {
                _editor.value = current.copy(saveFailed = true)
            }
        }
    }
}
