package com.example.studentgradeapp

import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.studentgradeapp.adapter.StudentAdapter
import com.example.studentgradeapp.calculator.GradeCalculator
import com.example.studentgradeapp.excel.ExcelParser
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : AppCompatActivity() {

    // ── Views ─────────────────────────────────────────────────────────────
    private lateinit var btnUpload:     Button
    private lateinit var recyclerView:  RecyclerView
    private lateinit var progressBar:   ProgressBar
    private lateinit var tvEmptyState:  TextView
    private lateinit var tvFileInfo:    TextView

    // ── Helpers ───────────────────────────────────────────────────────────
    private val adapter        = StudentAdapter()
    private val excelParser    = ExcelParser()
    private val gradeCalculator = GradeCalculator()

    // ── File picker launcher ──────────────────────────────────────────────
    private val filePickerLauncher = registerForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            processFile(uri)
        } else {
            Toast.makeText(this, "No file selected.", Toast.LENGTH_SHORT).show()
        }
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        bindViews()
        setupRecyclerView()

        btnUpload.setOnClickListener {
            // Filter for .xlsx spreadsheet MIME type
            filePickerLauncher.launch(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────

    private fun bindViews() {
        btnUpload    = findViewById(R.id.btnUploadFile)
        recyclerView = findViewById(R.id.recyclerViewStudents)
        progressBar  = findViewById(R.id.progressBar)
        tvEmptyState = findViewById(R.id.tvEmptyState)
        tvFileInfo   = findViewById(R.id.tvFileInfo)
    }

    private fun setupRecyclerView() {
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter
    }

    /**
     * Reads the file at [uri], parses it, computes grades, and populates the list.
     * Heavy I/O is performed on [Dispatchers.IO] to keep the UI thread free.
     */
    private fun processFile(uri: Uri) {
        setLoadingState(true)

        lifecycleScope.launch {
            try {
                val students = withContext(Dispatchers.IO) {
                    // Open an InputStream via ContentResolver (no storage permission needed)
                    val inputStream = contentResolver.openInputStream(uri)
                        ?: throw IllegalStateException("Unable to open the selected file.")

                    inputStream.use { stream ->
                        val parsed = excelParser.parse(stream)
                        gradeCalculator.calculate(parsed)
                    }
                }

                // ── Back on main thread ──────────────────────────────────
                if (students.isEmpty()) {
                    showEmptyState("No student records found in the file.")
                } else {
                    showResults(students.size, uri.lastPathSegment ?: "file")
                    adapter.submitList(students)
                }

            } catch (e: Exception) {
                e.printStackTrace()
                showEmptyState("Error reading file.")
                Toast.makeText(
                    this@MainActivity,
                    "Failed to parse file: ${e.localizedMessage}",
                    Toast.LENGTH_LONG
                ).show()
            } finally {
                setLoadingState(false)
            }
        }
    }

    private fun setLoadingState(loading: Boolean) {
        progressBar.visibility  = if (loading) View.VISIBLE else View.GONE
        btnUpload.isEnabled     = !loading
    }

    private fun showEmptyState(message: String) {
        tvEmptyState.text       = message
        tvEmptyState.visibility = View.VISIBLE
        recyclerView.visibility = View.GONE
        tvFileInfo.visibility   = View.GONE
    }

    private fun showResults(count: Int, fileName: String) {
        tvEmptyState.visibility = View.GONE
        recyclerView.visibility = View.VISIBLE
        tvFileInfo.visibility   = View.VISIBLE
        tvFileInfo.text         = "Loaded $count student(s) from $fileName"
    }
}
