package dev.local.notetaker

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertTextContains
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Rule
import org.junit.Test

class NoteJourneyTest {
    @get:Rule val compose = createAndroidComposeRule<MainActivity>()

    @Test fun savedNoteCanBeReopened() {
        val args = InstrumentationRegistry.getArguments()
        val phase = args.getString("phase")
        val title = args.getString("smokeTitle") ?: "Journey ${System.nanoTime()}"
        val body = "A persisted note\n世界 📝"
        if (phase != "verify") {
            compose.onNodeWithText("New note").performClick()
            compose.onNodeWithText("Title").performTextInput(title)
            compose.onNodeWithText("Note").performTextInput(body)
            compose.onNodeWithText("Save", substring = false).performClick()
            compose.waitUntil(10_000) {
                compose.onAllNodesWithText("Saved on this device").fetchSemanticsNodes().isNotEmpty()
            }
            compose.onNodeWithText("Back").performClick()
            compose.onNodeWithText(title).assertIsDisplayed()
            if (phase == "seed") return
            compose.activityRule.scenario.recreate()
        }
        compose.waitUntil(10_000) {
            compose.onAllNodesWithText(title).fetchSemanticsNodes().isNotEmpty()
        }
        compose.onNodeWithText(title).performClick()
        compose.onNodeWithText(body).assertTextContains(body)
        compose.onNodeWithText("Saved on this device").assertIsDisplayed()
    }
}
