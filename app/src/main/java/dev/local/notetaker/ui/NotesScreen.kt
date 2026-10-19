package dev.local.notetaker.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import dev.local.notetaker.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotesScreen(model: NotesViewModel) {
    val notes by model.notes.collectAsStateWithLifecycle()
    val editor by model.editor.collectAsStateWithLifecycle()
    var confirmDiscard by remember { mutableStateOf(false) }
    fun leaveEditor() {
        if (editor?.dirty == true) confirmDiscard = true else model.close()
    }
    BackHandler(enabled = editor != null) { if (editor?.saving != true) leaveEditor() }
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(if (editor == null) R.string.app_name else R.string.edit_note)) },
                navigationIcon = {
                    if (editor != null) TextButton(onClick = ::leaveEditor, enabled = editor?.saving != true) {
                        Text(stringResource(R.string.back))
                    }
                },
            )
        },
        floatingActionButton = {
            if (editor == null) FloatingActionButton(onClick = model::create) {
                Text(stringResource(R.string.new_note), Modifier.padding(horizontal = 16.dp))
            }
        },
    ) { padding ->
        val current = editor
        if (current == null) {
            LazyColumn(Modifier.fillMaxSize().padding(padding), contentPadding = PaddingValues(bottom = 96.dp)) {
                if (notes.isEmpty()) item {
                    Text(stringResource(R.string.empty_notes), Modifier.padding(24.dp))
                }
                items(notes, key = { it.id }) { note ->
                    ListItem(
                        headlineContent = { Text(note.title.ifBlank { stringResource(R.string.untitled) }) },
                        supportingContent = { Text(note.body, maxLines = 2) },
                        modifier = Modifier.clickable { model.open(note) }.testTag("note-${note.id}"),
                    )
                }
            }
        } else {
            Column(
                Modifier.fillMaxSize().padding(padding).imePadding().padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                OutlinedTextField(
                    value = current.note.title,
                    onValueChange = { model.edit(it, current.note.body) },
                    label = { Text(stringResource(R.string.title)) },
                    enabled = !current.saving, singleLine = true, modifier = Modifier.fillMaxWidth(),
                )
                OutlinedTextField(
                    value = current.note.body,
                    onValueChange = { model.edit(current.note.title, it) },
                    label = { Text(stringResource(R.string.note)) },
                    enabled = !current.saving,
                    modifier = Modifier.fillMaxWidth().weight(1f),
                )
                Text(stringResource(when {
                    current.saveFailed -> R.string.save_failed
                    current.saving -> R.string.saving
                    current.dirty -> R.string.unsaved
                    else -> R.string.saved
                }))
                Button(onClick = model::save, enabled = current.dirty && !current.saving) {
                    Text(stringResource(R.string.save))
                }
            }
        }
    }
    if (confirmDiscard) AlertDialog(
        onDismissRequest = { confirmDiscard = false },
        title = { Text(stringResource(R.string.discard_title)) },
        text = { Text(stringResource(R.string.discard_message)) },
        confirmButton = {
            TextButton(onClick = { confirmDiscard = false; model.close() }) { Text(stringResource(R.string.discard)) }
        },
        dismissButton = {
            TextButton(onClick = { confirmDiscard = false }) { Text(stringResource(R.string.keep_editing)) }
        },
    )
}
